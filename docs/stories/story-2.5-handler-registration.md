# Story 2.5: Implement Handler Registration

**Status**: Draft
**Epic**: 2 - Message Bus Actor Implementation
**Priority**: P0 - Critical
**Estimated Points**: 5
**Dependencies**: Stories 2.1-2.4 (Core message bus functionality)

## Story

**As a** developer  
**I want** to register and unregister handlers dynamically  
**So that** I can manage message processing lifecycle

## Acceptance Criteria

- [ ] Dynamic handler registration for events, commands, and queries
- [ ] Handler unregistration with proper cleanup
- [ ] Validation of handler type compatibility
- [ ] Prevention of duplicate command/query handlers
- [ ] Support for weak reference handlers
- [ ] Handler lifecycle tracking with metrics
- [ ] Thread-safe registration/unregistration
- [ ] Bulk registration support for multiple handlers

## Dev Notes

### Registration Strategy
- Events: Multiple handlers allowed
- Commands: Single handler enforced
- Queries: Single handler per query/response pair
- Support both strong and weak references
- Clean up deallocated weak handlers automatically

### Key Considerations
- Registration must be thread-safe via actor
- Type safety must be enforced at compile time
- Handler removal must not affect in-flight messages
- Support handler migration during runtime

## Tasks

### Development Tasks
- [ ] Implement type-safe handler registration
- [ ] Create handler validation logic
- [ ] Add duplicate handler detection
- [ ] Implement weak reference support
- [ ] Create handler lifecycle management
- [ ] Add bulk registration APIs
- [ ] Implement handler migration support
- [ ] Create handler introspection APIs

### Implementation Details

#### Enhanced Handler Registration
```swift
// In MessageBusActor.swift

// MARK: - Handler Registration

func registerEventHandler<T: MessagePayload>(
    for payloadType: T.Type,
    id: String? = nil,
    weak target: AnyObject? = nil,
    handler: @escaping (Event<T>) async -> Void
) -> HandlerRegistration {
    let key = String(describing: T.self)
    let handlerId = id ?? UUID().uuidString
    
    // Check for duplicate ID
    if let existingHandlers = eventHandlers[key],
       existingHandlers.contains(where: { $0.id == handlerId }) {
        logWarning("Handler with ID \(handlerId) already exists for \(T.self)")
    }
    
    let wrappedHandler = AnyEventHandler(
        id: handlerId,
        handler: handler,
        weakTarget: target
    )
    
    eventHandlers[key, default: []].append(wrappedHandler)
    metrics.eventHandlerCount += 1
    
    // Log registration
    if configuration.enableTracing {
        logHandlerRegistered(type: "Event", payload: T.self, id: handlerId)
    }
    
    // Return registration for lifecycle management
    return HandlerRegistration(
        id: handlerId,
        type: .event(T.self),
        unregister: { [weak self] in
            await self?.unregisterEventHandler(id: handlerId, for: T.self)
        }
    )
}

func registerCommandHandler<T: MessagePayload>(
    for payloadType: T.Type,
    handler: @escaping (Command<T>) async throws -> CommandResult
) throws -> HandlerRegistration {
    let key = String(describing: T.self)
    
    // Enforce single handler constraint
    guard commandHandlers[key] == nil else {
        throw MessageBusError.handlerAlreadyRegistered(
            message: "Command handler already registered for \(T.self)"
        )
    }
    
    let handlerId = UUID().uuidString
    commandHandlers[key] = AnyCommandHandler(
        id: handlerId,
        handler: handler
    )
    metrics.commandHandlerCount += 1
    
    // Log registration
    if configuration.enableTracing {
        logHandlerRegistered(type: "Command", payload: T.self, id: handlerId)
    }
    
    return HandlerRegistration(
        id: handlerId,
        type: .command(T.self),
        unregister: { [weak self] in
            await self?.unregisterCommandHandler(for: T.self)
        }
    )
}

func registerQueryHandler<T: MessagePayload, R: MessagePayload>(
    for payloadType: T.Type,
    responseType: R.Type,
    handler: @escaping (Query<T, R>) async throws -> Response<R>
) throws -> HandlerRegistration {
    let key = "\(String(describing: T.self))->\(String(describing: R.self))"
    
    // Enforce single handler constraint
    guard queryHandlers[key] == nil else {
        throw MessageBusError.handlerAlreadyRegistered(
            message: "Query handler already registered for \(T.self) -> \(R.self)"
        )
    }
    
    let handlerId = UUID().uuidString
    queryHandlers[key] = AnyQueryHandler(
        id: handlerId,
        handler: handler
    )
    metrics.queryHandlerCount += 1
    
    // Log registration
    if configuration.enableTracing {
        logHandlerRegistered(
            type: "Query",
            payload: T.self,
            response: R.self,
            id: handlerId
        )
    }
    
    return HandlerRegistration(
        id: handlerId,
        type: .query(T.self, R.self),
        unregister: { [weak self] in
            await self?.unregisterQueryHandler(for: T.self, responseType: R.self)
        }
    )
}

// MARK: - Handler Unregistration

private func unregisterEventHandler<T: MessagePayload>(
    id: String,
    for payloadType: T.Type
) {
    let key = String(describing: T.self)
    
    eventHandlers[key]?.removeAll { $0.id == id }
    
    // Clean up empty arrays
    if eventHandlers[key]?.isEmpty == true {
        eventHandlers.removeValue(forKey: key)
    }
    
    metrics.eventHandlerCount = max(0, metrics.eventHandlerCount - 1)
    
    if configuration.enableTracing {
        logHandlerUnregistered(type: "Event", payload: T.self, id: id)
    }
}

private func unregisterCommandHandler<T: MessagePayload>(
    for payloadType: T.Type
) {
    let key = String(describing: T.self)
    
    if commandHandlers.removeValue(forKey: key) != nil {
        metrics.commandHandlerCount = max(0, metrics.commandHandlerCount - 1)
        
        if configuration.enableTracing {
            logHandlerUnregistered(type: "Command", payload: T.self)
        }
    }
}

private func unregisterQueryHandler<T: MessagePayload, R: MessagePayload>(
    for payloadType: T.Type,
    responseType: R.Type
) {
    let key = "\(String(describing: T.self))->\(String(describing: R.self))"
    
    if queryHandlers.removeValue(forKey: key) != nil {
        metrics.queryHandlerCount = max(0, metrics.queryHandlerCount - 1)
        
        if configuration.enableTracing {
            logHandlerUnregistered(type: "Query", payload: T.self, response: R.self)
        }
    }
}

// MARK: - Bulk Registration

func registerHandlers(_ registrations: [HandlerRegistrationRequest]) async throws -> [HandlerRegistration] {
    var results: [HandlerRegistration] = []
    
    for request in registrations {
        switch request {
        case .event(let type, let handler):
            let registration = registerEventHandler(
                for: type,
                handler: handler
            )
            results.append(registration)
            
        case .command(let type, let handler):
            let registration = try registerCommandHandler(
                for: type,
                handler: handler
            )
            results.append(registration)
            
        case .query(let type, let responseType, let handler):
            let registration = try registerQueryHandler(
                for: type,
                responseType: responseType,
                handler: handler
            )
            results.append(registration)
        }
    }
    
    return results
}

// MARK: - Handler Introspection

func getRegisteredHandlers() -> HandlerInfo {
    HandlerInfo(
        eventTypes: eventHandlers.keys.map { $0 },
        commandTypes: commandHandlers.keys.map { $0 },
        queryTypes: queryHandlers.keys.map { $0 },
        totalCount: metrics.eventHandlerCount + metrics.commandHandlerCount + metrics.queryHandlerCount
    )
}

func hasHandler<T: MessagePayload>(for messageType: MessageType, payload: T.Type) -> Bool {
    let key = String(describing: T.self)
    
    switch messageType {
    case .event:
        return eventHandlers[key]?.isEmpty == false
    case .command:
        return commandHandlers[key] != nil
    case .query:
        return queryHandlers.keys.contains { $0.hasPrefix(key) }
    }
}

// MARK: - Weak Reference Cleanup

func cleanupDeallocatedHandlers() async {
    var cleanedCount = 0
    
    // Clean event handlers
    for (key, handlers) in eventHandlers {
        let validHandlers = handlers.filter { !$0.isDeallocated }
        if validHandlers.count < handlers.count {
            eventHandlers[key] = validHandlers
            cleanedCount += handlers.count - validHandlers.count
        }
    }
    
    metrics.eventHandlerCount -= cleanedCount
    
    if cleanedCount > 0 && configuration.enableTracing {
        logInfo("Cleaned up \(cleanedCount) deallocated handlers")
    }
}
```

#### Handler Registration Types
```swift
// HandlerRegistration.swift

public struct HandlerRegistration: Sendable {
    public let id: String
    public let type: HandlerType
    private let unregister: @Sendable () async -> Void
    
    public func cancel() async {
        await unregister()
    }
}

public enum HandlerType: Sendable {
    case event(Any.Type)
    case command(Any.Type)
    case query(Any.Type, Any.Type)
}

public enum HandlerRegistrationRequest {
    case event(Any.Type, (Any) async -> Void)
    case command(Any.Type, (Any) async throws -> CommandResult)
    case query(Any.Type, Any.Type, (Any) async throws -> Any)
}

public struct HandlerInfo: Sendable {
    public let eventTypes: [String]
    public let commandTypes: [String]
    public let queryTypes: [String]
    public let totalCount: Int
    
    public var summary: String {
        """
        Registered Handlers:
        - Events: \(eventTypes.count) types
        - Commands: \(commandTypes.count) types
        - Queries: \(queryTypes.count) types
        - Total: \(totalCount) handlers
        """
    }
}
```

#### Enhanced Handler Wrappers
```swift
// Enhanced AnyEventHandler with weak reference support
private class AnyEventHandler {
    let id: String
    private let _handle: (Any) async -> Void
    private weak var weakTarget: AnyObject?
    
    var isDeallocated: Bool {
        weakTarget != nil && weakTarget == nil
    }
    
    init<T: MessagePayload>(
        id: String,
        handler: @escaping (Event<T>) async -> Void,
        weakTarget: AnyObject? = nil
    ) {
        self.id = id
        self.weakTarget = weakTarget
        self._handle = { event in
            guard let typedEvent = event as? Event<T> else { return }
            
            // Check if weak target still exists
            if weakTarget != nil && weakTarget == nil {
                return // Handler deallocated
            }
            
            await handler(typedEvent)
        }
    }
    
    func handle(_ event: Any) async {
        await _handle(event)
    }
}
```

### Testing Tasks
- [ ] Test handler registration type safety
- [ ] Test duplicate command handler prevention
- [ ] Test duplicate query handler prevention
- [ ] Test handler unregistration cleanup
- [ ] Test weak reference cleanup
- [ ] Test bulk registration
- [ ] Test handler introspection
- [ ] Test concurrent registration safety
- [ ] Test handler migration scenarios

### Test Scenarios
```swift
// Test duplicate command handler prevention
func testDuplicateCommandHandlerPrevention() async throws {
    let bus = MessageBus()
    
    // Register first handler
    _ = try await bus.registerCommandHandler(for: TestPayload.self) { _ in
        return .success
    }
    
    // Attempt to register second handler should fail
    await XCTAssertThrowsError(
        try await bus.registerCommandHandler(for: TestPayload.self) { _ in
            return .success
        }
    ) { error in
        guard case MessageBusError.handlerAlreadyRegistered = error else {
            XCTFail("Expected handlerAlreadyRegistered error")
            return
        }
    }
}

// Test weak reference cleanup
func testWeakReferenceCleanup() async {
    let bus = MessageBus()
    var handler: TestHandler? = TestHandler()
    
    // Register with weak reference
    await bus.registerEventHandler(
        for: TestPayload.self,
        weak: handler
    ) { event in
        handler?.handle(event)
    }
    
    // Verify handler is called
    var called = false
    handler?.onHandle = { _ in called = true }
    
    await bus.publish(Event(source: .application, payload: TestPayload()))
    XCTAssertTrue(called)
    
    // Deallocate handler
    handler = nil
    
    // Cleanup should remove deallocated handler
    await bus.cleanupDeallocatedHandlers()
    
    // Publishing should not crash
    let count = await bus.publish(Event(source: .application, payload: TestPayload()))
    XCTAssertEqual(count, 0) // No handlers remain
}

// Test bulk registration
func testBulkRegistration() async throws {
    let bus = MessageBus()
    
    let registrations = [
        .event(TestPayload1.self, { _ in }),
        .event(TestPayload2.self, { _ in }),
        .command(TestCommand.self, { _ in .success }),
        .query(TestQuery.self, TestResponse.self, { _ in 
            Response(source: .domain, payload: TestResponse(), success: true)
        })
    ]
    
    let results = try await bus.registerHandlers(registrations)
    XCTAssertEqual(results.count, 4)
    
    // Verify all handlers are registered
    let info = await bus.getRegisteredHandlers()
    XCTAssertEqual(info.eventTypes.count, 2)
    XCTAssertEqual(info.commandTypes.count, 1)
    XCTAssertEqual(info.queryTypes.count, 1)
}
```

## Definition of Done

- [ ] Type-safe registration implemented
- [ ] Duplicate handler prevention working
- [ ] Weak reference support functional
- [ ] Handler cleanup automated
- [ ] Bulk registration API complete
- [ ] Introspection APIs functional
- [ ] Thread safety verified
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
- [ ] Sources/SwiftMessageBus/Core/HandlerRegistration.swift
- [ ] Sources/SwiftMessageBus/Core/HandlerInfo.swift
- [ ] Sources/SwiftMessageBus/Core/HandlerWrappers.swift (updated)
- [ ] Tests/SwiftMessageBusTests/HandlerRegistrationTests.swift
- [ ] Tests/SwiftMessageBusTests/WeakReferenceTests.swift
- [ ] Tests/SwiftMessageBusTests/BulkRegistrationTests.swift

### Change Log
- 