# Story 2.1: Implement MessageBusActor Core

**Status**: Draft
**Epic**: 2 - Message Bus Actor Implementation
**Priority**: P0 - Critical
**Estimated Points**: 8
**Dependencies**: Stories 1.1-1.3 (Core foundation must be complete)

## Story

**As a** framework user  
**I want** a thread-safe message bus  
**So that** I can publish and handle messages without concurrency issues

## Acceptance Criteria

- [ ] MessageBusActor implemented as Swift actor for thread safety
- [ ] Internal subscription storage with type-safe handler registry
- [ ] Message queue with priority support using swift-collections
- [ ] Configuration support for bus behavior
- [ ] Proper actor isolation for all mutable state
- [ ] Public MessageBus facade for user-friendly API
- [ ] Logging hooks for debugging support

## Dev Notes

### Architecture Design
- Use actor model for guaranteed thread safety
- Separate public API (MessageBus) from internal actor (MessageBusActor)
- Use type erasure for heterogeneous handler storage
- Leverage swift-collections for performance data structures

### Key Components
1. MessageBusActor - Internal actor managing state
2. MessageBus - Public API facade
3. HandlerRegistry - Type-indexed subscription storage
4. MessageQueue - Priority queue for message processing
5. BusConfiguration - Runtime configuration

## Tasks

### Development Tasks
- [ ] Create Core folder structure
- [ ] Implement MessageBusActor with actor isolation
- [ ] Create HandlerRegistry for type-safe storage
- [ ] Implement MessageQueue with priority support
- [ ] Create BusConfiguration type
- [ ] Implement MessageBus public API
- [ ] Add subscription lifecycle management
- [ ] Implement weak reference support for handlers

### Implementation Details

#### MessageBusActor.swift
```swift
import Foundation
import Collections

/// Internal actor managing all message bus state and operations
actor MessageBusActor {
    // MARK: - Properties
    
    private var eventHandlers: [String: [AnyEventHandler]] = [:]
    private var commandHandlers: [String: AnyCommandHandler] = [:]
    private var queryHandlers: [String: AnyQueryHandler] = [:]
    private var messageQueue: Deque<QueuedMessage> = []
    private let configuration: BusConfiguration
    private var isProcessing = false
    
    // MARK: - Metrics
    
    private(set) var metrics = BusMetrics()
    
    // MARK: - Initialization
    
    init(configuration: BusConfiguration = .default) {
        self.configuration = configuration
    }
    
    // MARK: - Event Publishing
    
    func publish<T: MessagePayload>(_ event: Event<T>) async -> Int {
        metrics.messagesPublished += 1
        let startTime = Date()
        
        // Get type-safe handlers
        let key = String(describing: T.self)
        let handlers = eventHandlers[key] ?? []
        
        // Execute all handlers asynchronously
        await withTaskGroup(of: Void.self) { group in
            for handler in handlers {
                group.addTask {
                    await handler.handle(event)
                }
            }
        }
        
        let duration = Date().timeIntervalSince(startTime)
        metrics.totalProcessingTime += duration
        metrics.messagesProcessed += 1
        
        return handlers.count
    }
    
    // MARK: - Command Handling
    
    func send<T: MessagePayload>(_ command: Command<T>) async throws -> CommandResult {
        metrics.messagesPublished += 1
        
        let key = String(describing: T.self)
        guard let handler = commandHandlers[key] else {
            throw MessageBusError.noHandlerRegistered(message: "No handler for command type \(T.self)")
        }
        
        return try await handler.handle(command)
    }
    
    // MARK: - Query Processing
    
    func query<T: MessagePayload, R: MessagePayload>(_ query: Query<T, R>) async throws -> Response<R> {
        metrics.messagesPublished += 1
        
        let key = "\(String(describing: T.self))->\(String(describing: R.self))"
        guard let handler = queryHandlers[key] else {
            throw MessageBusError.noHandlerRegistered(message: "No handler for query type \(T.self)")
        }
        
        // Check cache if query is cacheable
        if query.cacheable, let cacheKey = query.cacheKey {
            // TODO: Implement cache lookup
        }
        
        let response = try await handler.handle(query)
        
        // Cache response if needed
        if query.cacheable, let cacheKey = query.cacheKey {
            // TODO: Cache response
        }
        
        return response
    }
    
    // MARK: - Subscription Management
    
    func subscribe<T: MessagePayload>(
        to payloadType: T.Type,
        handler: @escaping (Event<T>) async -> Void
    ) -> Subscription {
        let key = String(describing: T.self)
        let wrappedHandler = AnyEventHandler(handler: handler)
        
        eventHandlers[key, default: []].append(wrappedHandler)
        metrics.subscriptionCount += 1
        
        return Subscription(
            id: UUID(),
            unsubscribe: { [weak self] in
                await self?.unsubscribe(key: key, handler: wrappedHandler)
            }
        )
    }
    
    func handleCommand<T: MessagePayload>(
        _ payloadType: T.Type,
        handler: @escaping (Command<T>) async throws -> CommandResult
    ) {
        let key = String(describing: T.self)
        commandHandlers[key] = AnyCommandHandler(handler: handler)
    }
    
    func handleQuery<T: MessagePayload, R: MessagePayload>(
        _ payloadType: T.Type,
        responseType: R.Type,
        handler: @escaping (Query<T, R>) async throws -> Response<R>
    ) {
        let key = "\(String(describing: T.self))->\(String(describing: R.self))"
        queryHandlers[key] = AnyQueryHandler(handler: handler)
    }
    
    // MARK: - Private Methods
    
    private func unsubscribe(key: String, handler: AnyEventHandler) {
        eventHandlers[key]?.removeAll { $0.id == handler.id }
        metrics.subscriptionCount -= 1
    }
}

// MARK: - Type Erasure Wrappers

private class AnyEventHandler {
    let id = UUID()
    private let _handle: (Any) async -> Void
    
    init<T: MessagePayload>(handler: @escaping (Event<T>) async -> Void) {
        self._handle = { event in
            guard let typedEvent = event as? Event<T> else { return }
            await handler(typedEvent)
        }
    }
    
    func handle(_ event: Any) async {
        await _handle(event)
    }
}

private class AnyCommandHandler {
    private let _handle: (Any) async throws -> CommandResult
    
    init<T: MessagePayload>(handler: @escaping (Command<T>) async throws -> CommandResult) {
        self._handle = { command in
            guard let typedCommand = command as? Command<T> else {
                throw MessageBusError.typeMismatch
            }
            return try await handler(typedCommand)
        }
    }
    
    func handle(_ command: Any) async throws -> CommandResult {
        try await _handle(command)
    }
}

private class AnyQueryHandler {
    private let _handle: (Any) async throws -> Any
    
    init<T: MessagePayload, R: MessagePayload>(
        handler: @escaping (Query<T, R>) async throws -> Response<R>
    ) {
        self._handle = { query in
            guard let typedQuery = query as? Query<T, R> else {
                throw MessageBusError.typeMismatch
            }
            return try await handler(typedQuery)
        }
    }
    
    func handle<R: MessagePayload>(_ query: Any) async throws -> Response<R> {
        guard let response = try await _handle(query) as? Response<R> else {
            throw MessageBusError.typeMismatch
        }
        return response
    }
}
```

#### MessageBus.swift (Public API)
```swift
import Foundation

/// Public API for the message bus framework
public final class MessageBus: Sendable {
    private let actor: MessageBusActor
    
    public init(configuration: BusConfiguration = .default) {
        self.actor = MessageBusActor(configuration: configuration)
    }
    
    // MARK: - Event Publishing
    
    @discardableResult
    public func publish<T: MessagePayload>(_ event: Event<T>) async -> Int {
        await actor.publish(event)
    }
    
    // MARK: - Command Handling
    
    public func send<T: MessagePayload>(_ command: Command<T>) async throws -> CommandResult {
        try await actor.send(command)
    }
    
    // MARK: - Query Processing
    
    public func query<T: MessagePayload, R: MessagePayload>(
        _ query: Query<T, R>
    ) async throws -> Response<R> {
        try await actor.query(query)
    }
    
    // MARK: - Subscription Management
    
    public func subscribe<T: MessagePayload>(
        to payloadType: T.Type,
        handler: @escaping (Event<T>) async -> Void
    ) async -> Subscription {
        await actor.subscribe(to: payloadType, handler: handler)
    }
    
    public func handleCommand<T: MessagePayload>(
        _ payloadType: T.Type,
        handler: @escaping (Command<T>) async throws -> CommandResult
    ) async {
        await actor.handleCommand(payloadType, handler: handler)
    }
    
    public func handleQuery<T: MessagePayload, R: MessagePayload>(
        _ payloadType: T.Type,
        responseType: R.Type,
        handler: @escaping (Query<T, R>) async throws -> Response<R>
    ) async {
        await actor.handleQuery(payloadType, responseType: responseType, handler: handler)
    }
    
    // MARK: - Metrics
    
    public func getMetrics() async -> BusMetrics {
        await actor.metrics
    }
}
```

#### Supporting Types
```swift
// BusConfiguration.swift
public struct BusConfiguration: Sendable {
    public let maxQueueSize: Int
    public let processingTimeout: TimeInterval
    public let enableMetrics: Bool
    public let enableTracing: Bool
    public let logLevel: LogLevel
    
    public static let `default` = BusConfiguration(
        maxQueueSize: 10000,
        processingTimeout: 30.0,
        enableMetrics: true,
        enableTracing: false,
        logLevel: .info
    )
}

// BusMetrics.swift
public struct BusMetrics: Sendable {
    public var messagesPublished: Int = 0
    public var messagesProcessed: Int = 0
    public var totalProcessingTime: TimeInterval = 0
    public var errorCount: Int = 0
    public var subscriptionCount: Int = 0
    
    public var averageLatency: TimeInterval {
        guard messagesProcessed > 0 else { return 0 }
        return totalProcessingTime / Double(messagesProcessed)
    }
}

// Subscription.swift
public struct Subscription: Sendable {
    public let id: UUID
    private let unsubscribe: @Sendable () async -> Void
    
    public func cancel() async {
        await unsubscribe()
    }
}

// CommandResult.swift
public enum CommandResult: Sendable {
    case success
    case failure(String)
}

// MessageBusError.swift
public enum MessageBusError: Error {
    case noHandlerRegistered(message: String)
    case typeMismatch
    case timeout
    case queueFull
}
```

### Testing Tasks
- [ ] Test actor thread safety with concurrent operations
- [ ] Test subscription lifecycle management
- [ ] Test handler type safety
- [ ] Test metrics collection
- [ ] Test configuration application
- [ ] Memory leak tests for handler references
- [ ] Performance baseline tests

## Definition of Done

- [ ] MessageBusActor fully implemented
- [ ] All mutable state properly isolated
- [ ] Public API clean and intuitive
- [ ] Unit tests achieve >90% coverage
- [ ] No data races detected
- [ ] Performance baseline established
- [ ] Documentation complete

## Dev Agent Record

### Agent Model Used
- 

### Debug Log References
- 

### Completion Notes
- 

### File List
- [ ] Sources/SwiftMessageBus/Core/MessageBusActor.swift
- [ ] Sources/SwiftMessageBus/Public/MessageBus.swift
- [ ] Sources/SwiftMessageBus/Core/BusConfiguration.swift
- [ ] Sources/SwiftMessageBus/Core/BusMetrics.swift
- [ ] Sources/SwiftMessageBus/Core/Subscription.swift
- [ ] Sources/SwiftMessageBus/Core/CommandResult.swift
- [ ] Sources/SwiftMessageBus/Core/MessageBusError.swift
- [ ] Tests/SwiftMessageBusTests/Core/MessageBusActorTests.swift
- [ ] Tests/SwiftMessageBusTests/Core/ThreadSafetyTests.swift

### Change Log
- 