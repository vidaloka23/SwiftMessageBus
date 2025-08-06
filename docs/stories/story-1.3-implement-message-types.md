# Story 1.3: Implement Message Type Structs

**Status**: Draft
**Epic**: 1 - Core Foundation and Package Setup
**Priority**: P0 - Critical
**Estimated Points**: 8
**Dependencies**: Story 1.2 (Core protocols)

## Story

**As a** framework user  
**I want** concrete message type implementations  
**So that** I can send commands, queries, and events

## Acceptance Criteria

- [ ] Command<T: MessagePayload> struct fully implemented with provided code
- [ ] Query<T: MessagePayload, R: MessagePayload> struct fully implemented
- [ ] Event<T: MessagePayload> struct fully implemented
- [ ] Response<T: MessagePayload> struct fully implemented
- [ ] All types are Codable and Sendable compliant
- [ ] Correlation ID support built into all types
- [ ] Query caching configuration supported
- [ ] Comprehensive unit tests with 100% coverage

## Dev Notes

### Implementation Source
The user has provided complete implementations for all message types. These should be copied exactly as provided, ensuring they integrate with the protocols defined in Story 1.2.

### Key Features to Implement
- Generic payload types with MessagePayload constraint
- Layer-based routing with source/destination
- Built-in correlation ID for request-response tracking
- Query caching with configurable TTL
- Metadata support for cross-cutting concerns
- Custom Codable implementation for Query type

## Tasks

### Development Tasks
- [ ] Create Messages folder in Sources/SwiftMessageBus/
- [ ] Copy provided Command<T> implementation to Command.swift
- [ ] Copy provided Query<T,R> implementation to Query.swift
- [ ] Copy provided Event<T> implementation to Event.swift
- [ ] Copy provided Response<T> implementation to Response.swift
- [ ] Ensure all types conform to MessageProtocol
- [ ] Add DocC documentation enhancements if needed
- [ ] Verify Sendable compliance

### Implementation Notes

#### Command.swift
```swift
import Foundation

// MARK: - Command

/// Message representing an action that changes system state.
///
/// Commands follow the Command pattern and should be named as imperative verbs
/// (e.g., CreateUser, UpdateProduct, DeleteOrder). Each command type should have
/// exactly one handler registered in the MessageBus.
public struct Command<T: MessagePayload>: MessageProtocol, Codable {
    // [Copy exact implementation from provided code]
    // Includes: init, properties, Codable conformance
}
```

#### Query.swift
```swift
import Foundation

// MARK: - Query

/// Message representing a request for data without side effects.
///
/// Queries follow the Query pattern and should be named as questions or getters
/// (e.g., GetUserById, FindProductsByCategory). Each query type should have
/// exactly one handler that returns the expected response type.
public struct Query<T: MessagePayload, R: MessagePayload>: MessageProtocol, Codable {
    // [Copy exact implementation from provided code]
    // Note: Custom Codable implementation for responseType handling
    // Includes: cacheable, cacheKey, timeout properties
}
```

#### Event.swift
```swift
import Foundation

// MARK: - Event

/// Message representing a fact about something that has occurred.
///
/// Events follow the Event Sourcing pattern and should be named in past tense
/// (e.g., UserCreated, OrderShipped, PaymentProcessed). Multiple handlers can
/// subscribe to the same event type, and all will be notified when published.
public struct Event<T: MessagePayload>: MessageProtocol, Codable {
    // [Copy exact implementation from provided code]
}
```

#### Response.swift
```swift
import Foundation

// MARK: - Response

/// Message representing a response to a query.
///
/// Responses wrap the result of a query handler, including both successful
/// results and error information. The correlationId should match the original
/// query's ID to enable request-response correlation.
public struct Response<T: MessagePayload>: MessageProtocol, Codable {
    // [Copy exact implementation from provided code]
    // Includes: success flag and error message
}
```

### Testing Tasks
- [ ] Test Command creation and property access
- [ ] Test Query with caching configuration
- [ ] Test Event broadcasting scenarios
- [ ] Test Response success/failure states
- [ ] Test Codable encoding/decoding for all types
- [ ] Test correlation ID propagation
- [ ] Test generic type constraints
- [ ] Test Query custom Codable implementation
- [ ] Memory leak tests for retained references

### Test Scenarios
- [ ] Create commands with various payload types
- [ ] Create cacheable vs non-cacheable queries
- [ ] Test query timeout configuration
- [ ] Test event with nil destination (broadcast)
- [ ] Test response with error states
- [ ] Test metadata propagation
- [ ] Test Layer routing validation

## Definition of Done

- [ ] All message types compile without warnings
- [ ] Exact implementation from provided code maintained
- [ ] Unit tests achieve 100% code coverage
- [ ] Codable round-trip tests pass
- [ ] Sendable compliance verified
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
- [ ] Sources/SwiftMessageBus/Messages/Command.swift
- [ ] Sources/SwiftMessageBus/Messages/Query.swift
- [ ] Sources/SwiftMessageBus/Messages/Event.swift
- [ ] Sources/SwiftMessageBus/Messages/Response.swift
- [ ] Tests/SwiftMessageBusTests/Messages/CommandTests.swift
- [ ] Tests/SwiftMessageBusTests/Messages/QueryTests.swift
- [ ] Tests/SwiftMessageBusTests/Messages/EventTests.swift
- [ ] Tests/SwiftMessageBusTests/Messages/ResponseTests.swift

### Change Log
- 