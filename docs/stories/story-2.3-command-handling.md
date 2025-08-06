# Story 2.3: Implement Command Handling

**Status**: Draft
**Epic**: 2 - Message Bus Actor Implementation  
**Priority**: P0 - Critical
**Estimated Points**: 5
**Dependencies**: Story 2.1 (MessageBusActor core)

## Story

**As a** developer  
**I want** to send commands with results  
**So that** I can implement CQRS patterns

## Acceptance Criteria

- [ ] send<T>(_ command: Command<T>) method returns CommandResult
- [ ] Commands have exactly one handler (validation enforced)
- [ ] Throws error if no handler registered
- [ ] Throws error if multiple handlers registered
- [ ] Timeout support with configurable duration
- [ ] Layer routing validation enforced
- [ ] Correlation ID maintained for tracking
- [ ] Performance: Can handle 5K+ commands/second

## Dev Notes

### Command Handling Strategy
- Commands are one-to-one (single handler)
- Commands modify state and return results
- Must validate single handler constraint
- Timeout prevents hanging on slow handlers
- Layer routing must be valid

### Key Differences from Events
- Single handler only (not multiple)
- Returns result (not fire-and-forget)
- Can throw errors (events don't)
- Has timeout (events don't)

## Tasks

### Development Tasks
- [ ] Implement send method with result handling
- [ ] Add single-handler validation
- [ ] Implement timeout mechanism
- [ ] Add layer routing validation
- [ ] Create comprehensive error handling
- [ ] Add command retry support (optional)
- [ ] Implement command validation hooks

### Implementation Details

#### Enhanced Command Handling
```swift
// In MessageBusActor.swift

func send<T: MessagePayload>(_ command: Command<T>) async throws -> CommandResult {
    metrics.messagesPublished += 1
    let startTime = Date()
    
    // Layer routing validation
    if let destination = command.destination {
        guard command.source.canRoute(to: destination) else {
            metrics.errorCount += 1
            throw MessageBusError.routingViolation(
                from: command.source,
                to: destination,
                message: "Invalid layer routing for command"
            )
        }
    }
    
    // Get handler
    let key = String(describing: T.self)
    guard let handler = commandHandlers[key] else {
        metrics.errorCount += 1
        throw MessageBusError.noHandlerRegistered(
            message: "No handler registered for command type: \(T.self)"
        )
    }
    
    // Create timeout task
    let timeoutDuration = command.metadata["timeout"]
        .flatMap { TimeInterval($0) }
        ?? configuration.defaultCommandTimeout
    
    do {
        // Execute with timeout
        let result = try await withThrowingTaskGroup(of: CommandResult.self) { group in
            // Add handler task
            group.addTask {
                try await Task.withLocal(\.correlationId, boundTo: command.correlationId) {
                    try await handler.handle(command)
                }
            }
            
            // Add timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeoutDuration * 1_000_000_000))
                throw MessageBusError.timeout(
                    message: "Command timed out after \(timeoutDuration) seconds"
                )
            }
            
            // Return first result (either success or timeout)
            guard let result = try await group.next() else {
                throw MessageBusError.internalError("No result from command handler")
            }
            
            // Cancel remaining tasks
            group.cancelAll()
            
            return result
        }
        
        // Update metrics
        let duration = Date().timeIntervalSince(startTime)
        metrics.totalProcessingTime += duration
        metrics.messagesProcessed += 1
        
        // Log if enabled
        if configuration.enableTracing {
            logCommandExecuted(command, result: result, duration: duration)
        }
        
        return result
        
    } catch {
        metrics.errorCount += 1
        
        // Log error
        logCommandError(command, error: error)
        
        // Wrap non-MessageBusError in command failure
        if error is MessageBusError {
            throw error
        } else {
            throw MessageBusError.commandExecutionFailed(
                message: "Command failed: \(error.localizedDescription)",
                underlyingError: error
            )
        }
    }
}

func handleCommand<T: MessagePayload>(
    _ payloadType: T.Type,
    handler: @escaping (Command<T>) async throws -> CommandResult
) throws {
    let key = String(describing: T.self)
    
    // Validate single handler constraint
    if commandHandlers[key] != nil {
        throw MessageBusError.handlerAlreadyRegistered(
            message: "Handler already registered for command type: \(T.self). Commands must have exactly one handler."
        )
    }
    
    commandHandlers[key] = AnyCommandHandler(handler: handler)
    metrics.commandHandlerCount += 1
}

func removeCommandHandler<T: MessagePayload>(for payloadType: T.Type) {
    let key = String(describing: T.self)
    if commandHandlers.removeValue(forKey: key) != nil {
        metrics.commandHandlerCount -= 1
    }
}
```

#### Enhanced Command Result
```swift
// CommandResult.swift

public enum CommandResult: Sendable, Equatable {
    case success
    case successWithData(Any)
    case failure(String)
    case validationError([String])
    
    public var isSuccess: Bool {
        switch self {
        case .success, .successWithData:
            return true
        case .failure, .validationError:
            return false
        }
    }
}

// Make Any Equatable for testing
extension CommandResult {
    public static func == (lhs: CommandResult, rhs: CommandResult) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success):
            return true
        case (.failure(let l), .failure(let r)):
            return l == r
        case (.validationError(let l), .validationError(let r)):
            return l == r
        case (.successWithData, .successWithData):
            return true // Can't compare Any, assume equal for testing
        default:
            return false
        }
    }
}
```

#### Command Validation
```swift
// CommandValidator.swift

public protocol CommandValidator {
    associatedtype PayloadType: MessagePayload
    func validate(_ command: Command<PayloadType>) -> [String]
}

// In MessageBusActor
private var commandValidators: [String: Any] = [:]

func registerValidator<T: MessagePayload>(
    for payloadType: T.Type,
    validator: any CommandValidator
) {
    let key = String(describing: T.self)
    commandValidators[key] = validator
}

// In send method, before handler execution:
if let validator = commandValidators[key] {
    let errors = validator.validate(command)
    if !errors.isEmpty {
        return .validationError(errors)
    }
}
```

#### Enhanced Error Types
```swift
// MessageBusError.swift (additions)

public enum MessageBusError: Error, Equatable {
    case noHandlerRegistered(message: String)
    case handlerAlreadyRegistered(message: String)
    case typeMismatch
    case timeout(message: String)
    case queueFull
    case routingViolation(from: Layer, to: Layer, message: String)
    case commandExecutionFailed(message: String, underlyingError: Error?)
    case internalError(String)
    case handlerDeallocated
    
    public static func == (lhs: MessageBusError, rhs: MessageBusError) -> Bool {
        // Simplified equality for testing
        switch (lhs, rhs) {
        case (.noHandlerRegistered(let l), .noHandlerRegistered(let r)):
            return l == r
        case (.timeout(let l), .timeout(let r)):
            return l == r
        // ... other cases
        default:
            return false
        }
    }
}
```

### Testing Tasks
- [ ] Test single handler constraint
- [ ] Test handler already registered error
- [ ] Test no handler registered error
- [ ] Test command timeout
- [ ] Test layer routing validation
- [ ] Test correlation ID propagation
- [ ] Test command validation
- [ ] Performance test with 5K commands/second
- [ ] Test error handling and recovery

### Test Scenarios
```swift
// Test single handler constraint
func testSingleHandlerConstraint() async throws {
    let bus = MessageBus()
    
    // Register first handler
    await bus.handleCommand(TestPayload.self) { _ in
        return .success
    }
    
    // Attempt to register second handler should fail
    await XCTAssertThrowsError(
        try await bus.handleCommand(TestPayload.self) { _ in
            return .success
        }
    ) { error in
        XCTAssert(error is MessageBusError)
    }
}

// Test command timeout
func testCommandTimeout() async throws {
    let bus = MessageBus(configuration: .init(defaultCommandTimeout: 0.1))
    
    await bus.handleCommand(TestPayload.self) { _ in
        // Simulate slow handler
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        return .success
    }
    
    let command = Command(source: .application, payload: TestPayload())
    
    await XCTAssertThrowsError(try await bus.send(command)) { error in
        guard case MessageBusError.timeout = error else {
            XCTFail("Expected timeout error")
            return
        }
    }
}
```

## Definition of Done

- [ ] Command handling fully functional
- [ ] Single handler constraint enforced
- [ ] Timeout mechanism working
- [ ] Layer routing validated
- [ ] Error handling comprehensive
- [ ] Correlation ID maintained
- [ ] Performance target met (5K+ commands/sec)
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
- [ ] Sources/SwiftMessageBus/Core/CommandResult.swift (enhanced)
- [ ] Sources/SwiftMessageBus/Core/CommandValidator.swift
- [ ] Sources/SwiftMessageBus/Core/MessageBusError.swift (updated)
- [ ] Tests/SwiftMessageBusTests/CommandHandlingTests.swift
- [ ] Tests/SwiftMessageBusTests/CommandTimeoutTests.swift
- [ ] Tests/SwiftMessageBusTests/CommandValidationTests.swift

### Change Log
- 