# Story 2.2: Implement Event Publishing

**Status**: Draft
**Epic**: 2 - Message Bus Actor Implementation
**Priority**: P0 - Critical
**Estimated Points**: 5
**Dependencies**: Story 2.1 (MessageBusActor core)

## Story

**As a** developer  
**I want** to publish events to multiple subscribers  
**So that** I can implement event-driven patterns

## Acceptance Criteria

- [ ] publish<T>(_ event: Event<T>) method fully functional
- [ ] Multiple handlers can subscribe to same event type
- [ ] All handlers execute asynchronously and concurrently
- [ ] Returns count of handlers that processed the event
- [ ] Correlation ID propagation through event chain
- [ ] Layer-based routing respects source/destination rules
- [ ] Handlers execute even if one fails (fault isolation)
- [ ] Performance: Can handle 10K+ events/second

## Dev Notes

### Event Publishing Strategy
- Use TaskGroup for concurrent handler execution
- Isolate handler failures to prevent cascade
- Track execution metrics for monitoring
- Support both strong and weak handler references

### Key Considerations
- Events are fire-and-forget (no return value)
- Multiple subscribers allowed (one-to-many)
- Order of handler execution not guaranteed
- Failed handlers shouldn't affect others

## Tasks

### Development Tasks
- [ ] Enhance publish method in MessageBusActor
- [ ] Implement concurrent handler execution
- [ ] Add error isolation for failed handlers
- [ ] Implement correlation ID propagation
- [ ] Add layer-based routing validation
- [ ] Create event filtering support
- [ ] Add handler priority support

### Implementation Details

#### Enhanced Event Publishing
```swift
// In MessageBusActor.swift

func publish<T: MessagePayload>(_ event: Event<T>) async -> Int {
    metrics.messagesPublished += 1
    let startTime = Date()
    
    // Layer routing validation
    if let destination = event.destination {
        guard event.source.canRoute(to: destination) else {
            // Log routing violation but don't throw
            logRoutingViolation(from: event.source, to: destination)
            metrics.errorCount += 1
            return 0
        }
    }
    
    // Get type-safe handlers
    let key = String(describing: T.self)
    var handlers = eventHandlers[key] ?? []
    
    // Apply destination filtering if specified
    if let destination = event.destination {
        handlers = handlers.filter { handler in
            handler.acceptsLayer(destination)
        }
    }
    
    // Sort by priority if enabled
    if configuration.enablePriorityHandling {
        handlers.sort { $0.priority > $1.priority }
    }
    
    // Track successful executions
    var successCount = 0
    
    // Execute all handlers concurrently with error isolation
    await withTaskGroup(of: Bool.self) { group in
        for handler in handlers {
            group.addTask {
                do {
                    // Propagate correlation ID to handler context
                    await Task.withLocal(\.correlationId, boundTo: event.correlationId) {
                        await handler.handle(event)
                    }
                    return true
                } catch {
                    // Log error but don't propagate
                    self.logHandlerError(error, for: event)
                    return false
                }
            }
        }
        
        // Collect results
        for await success in group {
            if success {
                successCount += 1
            } else {
                metrics.errorCount += 1
            }
        }
    }
    
    // Update metrics
    let duration = Date().timeIntervalSince(startTime)
    metrics.totalProcessingTime += duration
    metrics.messagesProcessed += 1
    
    // Log if enabled
    if configuration.enableTracing {
        logEventPublished(event, handlerCount: handlers.count, successCount: successCount, duration: duration)
    }
    
    return successCount
}

// Enhanced handler wrapper with priority and layer filtering
private class AnyEventHandler {
    let id = UUID()
    let priority: HandlerPriority
    let acceptedLayers: Set<Layer>?
    private let _handle: (Any) async throws -> Void
    private weak var weakTarget: AnyObject?
    
    init<T: MessagePayload>(
        handler: @escaping (Event<T>) async -> Void,
        priority: HandlerPriority = .normal,
        acceptedLayers: Set<Layer>? = nil,
        weakTarget: AnyObject? = nil
    ) {
        self.priority = priority
        self.acceptedLayers = acceptedLayers
        self.weakTarget = weakTarget
        self._handle = { event in
            guard let typedEvent = event as? Event<T> else {
                throw MessageBusError.typeMismatch
            }
            await handler(typedEvent)
        }
    }
    
    func handle(_ event: Any) async throws {
        // Check if weak target still exists
        if weakTarget != nil && weakTarget == nil {
            throw MessageBusError.handlerDeallocated
        }
        try await _handle(event)
    }
    
    func acceptsLayer(_ layer: Layer) -> Bool {
        guard let acceptedLayers = acceptedLayers else { return true }
        return acceptedLayers.contains(layer)
    }
}

// Handler priority enum
public enum HandlerPriority: Int, Comparable {
    case critical = 1000
    case high = 750
    case normal = 500
    case low = 250
    case background = 0
    
    public static func < (lhs: HandlerPriority, rhs: HandlerPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
```

#### Enhanced Subscription with Options
```swift
// In MessageBus.swift

public struct SubscriptionOptions: Sendable {
    public let priority: HandlerPriority
    public let acceptedLayers: Set<Layer>?
    public let weakTarget: AnyObject?
    
    public static let `default` = SubscriptionOptions(
        priority: .normal,
        acceptedLayers: nil,
        weakTarget: nil
    )
    
    public init(
        priority: HandlerPriority = .normal,
        acceptedLayers: Set<Layer>? = nil,
        weakTarget: AnyObject? = nil
    ) {
        self.priority = priority
        self.acceptedLayers = acceptedLayers
        self.weakTarget = weakTarget
    }
}

public func subscribe<T: MessagePayload>(
    to payloadType: T.Type,
    options: SubscriptionOptions = .default,
    handler: @escaping (Event<T>) async -> Void
) async -> Subscription {
    await actor.subscribe(
        to: payloadType,
        options: options,
        handler: handler
    )
}
```

#### Correlation ID Task Local
```swift
// In a new file: TaskLocal+CorrelationID.swift

extension Task where Success == Never, Failure == Never {
    @TaskLocal
    static var correlationId: String?
}
```

### Testing Tasks
- [ ] Test multiple subscribers receive events
- [ ] Test concurrent handler execution
- [ ] Test handler failure isolation
- [ ] Test correlation ID propagation
- [ ] Test layer routing validation
- [ ] Test handler priority ordering
- [ ] Test weak reference cleanup
- [ ] Performance test with 10K events/second
- [ ] Test memory usage with many subscribers

### Test Scenarios
```swift
// Test multiple subscribers
func testMultipleSubscribers() async {
    let bus = MessageBus()
    var received1 = false
    var received2 = false
    
    await bus.subscribe(to: TestPayload.self) { _ in
        received1 = true
    }
    
    await bus.subscribe(to: TestPayload.self) { _ in
        received2 = true
    }
    
    let event = Event(source: .application, payload: TestPayload())
    let count = await bus.publish(event)
    
    XCTAssertEqual(count, 2)
    XCTAssertTrue(received1)
    XCTAssertTrue(received2)
}

// Test handler isolation
func testHandlerFailureIsolation() async {
    let bus = MessageBus()
    var successfulHandlerCalled = false
    
    await bus.subscribe(to: TestPayload.self) { _ in
        throw TestError.expectedFailure
    }
    
    await bus.subscribe(to: TestPayload.self) { _ in
        successfulHandlerCalled = true
    }
    
    let event = Event(source: .application, payload: TestPayload())
    let count = await bus.publish(event)
    
    XCTAssertEqual(count, 1) // Only successful handler counted
    XCTAssertTrue(successfulHandlerCalled)
}
```

## Definition of Done

- [ ] Event publishing fully functional
- [ ] Concurrent handler execution verified
- [ ] Error isolation confirmed
- [ ] Layer routing working correctly
- [ ] Correlation ID propagation tested
- [ ] Performance target met (10K+ events/sec)
- [ ] Memory usage acceptable
- [ ] All tests passing
- [ ] Documentation updated

## Dev Agent Record

### Agent Model Used
- 

### Debug Log References
- 

### Completion Notes
- 

### File List
- [ ] Sources/SwiftMessageBus/Core/MessageBusActor.swift (updated)
- [ ] Sources/SwiftMessageBus/Core/HandlerPriority.swift
- [ ] Sources/SwiftMessageBus/Core/SubscriptionOptions.swift
- [ ] Sources/SwiftMessageBus/Core/TaskLocal+CorrelationID.swift
- [ ] Tests/SwiftMessageBusTests/EventPublishingTests.swift
- [ ] Tests/SwiftMessageBusTests/HandlerIsolationTests.swift
- [ ] Tests/SwiftMessageBusTests/PerformanceTests/EventThroughputTests.swift

### Change Log
- 