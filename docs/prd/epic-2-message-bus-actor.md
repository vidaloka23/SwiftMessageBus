# Epic 2: Message Bus Actor Implementation

## Epic Overview
Implement the core MessageBusActor that serves as the heart of the framework, managing all message routing, subscriptions, and handler execution with actor-based concurrency.

**Priority**: P0 - Critical
**Estimated Duration**: Week 2
**Dependencies**: Epic 1 (Core Foundation)

## Success Criteria
- [ ] MessageBusActor provides thread-safe message routing
- [ ] All message types (Event, Command, Query) are supported
- [ ] Layer-based routing works correctly
- [ ] Performance meets initial targets (10K+ msgs/sec)
- [ ] No race conditions or deadlocks

## User Stories

### Story 2.1: Implement MessageBusActor Core
**As a** framework user  
**I want** a thread-safe message bus  
**So that** I can publish and handle messages without concurrency issues

**Acceptance Criteria**:
- [ ] MessageBusActor implemented as Swift actor
- [ ] Internal state management for subscriptions
- [ ] Message queue with priority support
- [ ] Thread-safe handler registry
- [ ] Proper actor isolation

**Technical Tasks**:
- Create Sources/SwiftMessageBus/Core/MessageBusActor.swift
- Implement subscription storage with type safety
- Add priority queue for message processing
- Ensure actor isolation for all state
- Add logging hooks for debugging

### Story 2.2: Implement Event Publishing
**As a** developer  
**I want** to publish events to multiple subscribers  
**So that** I can implement event-driven patterns

**Acceptance Criteria**:
- [ ] publish<T>(_ event: Event<T>) method works
- [ ] Multiple handlers can subscribe to same event type
- [ ] Handlers execute asynchronously
- [ ] Returns count of handlers that processed event
- [ ] Correlation ID propagation works

**Technical Tasks**:
- Implement publish method in MessageBusActor
- Create handler dispatch mechanism
- Add handler execution tracking
- Implement correlation ID flow
- Write comprehensive tests

### Story 2.3: Implement Command Handling
**As a** developer  
**I want** to send commands with results  
**So that** I can implement CQRS patterns

**Acceptance Criteria**:
- [ ] send<T>(_ command: Command<T>) method works
- [ ] Commands have exactly one handler
- [ ] Returns CommandResult type
- [ ] Throws if no handler registered
- [ ] Timeout support implemented

**Technical Tasks**:
- Implement send method with result handling
- Add single-handler validation
- Create CommandResult type
- Implement timeout mechanism
- Add error handling for missing handlers

### Story 2.4: Implement Query Processing
**As a** developer  
**I want** to execute queries with responses  
**So that** I can retrieve data without side effects

**Acceptance Criteria**:
- [ ] query<T,R>(_ query: Query<T,R>) returns Response<R>
- [ ] Query caching when marked cacheable
- [ ] Cache key generation works correctly
- [ ] Timeout handling implemented
- [ ] Success/failure in Response type

**Technical Tasks**:
- Implement query method with generic response
- Create QueryCache implementation
- Add cache key generation logic
- Implement query timeout handling
- Write cache hit/miss tests

### Story 2.5: Implement Handler Registration
**As a** developer  
**I want** to register handlers for messages  
**So that** I can process different message types

**Acceptance Criteria**:
- [ ] Type-safe handler registration for all message types
- [ ] handleCommand<T> method works correctly
- [ ] handleQuery<T,R> method with response type
- [ ] subscribe<T> for events returns Subscription
- [ ] Handler lifecycle management (weak references)

**Technical Tasks**:
- Create handler registration methods
- Implement Subscription type for lifecycle
- Add weak reference support
- Create handler registry with type indexing
- Test memory management

### Story 2.6: Implement Layer-Based Routing
**As a** developer  
**I want** messages routed by architectural layer  
**So that** I can maintain clean architecture

**Acceptance Criteria**:
- [ ] Messages route based on source/destination layers
- [ ] Optional destination allows broadcast
- [ ] Layer validation prevents invalid routes
- [ ] Routing rules are configurable
- [ ] Performance overhead minimal

**Technical Tasks**:
- Create MessageRouter component
- Implement layer-based routing logic
- Add routing rule configuration
- Create routing validation
- Performance test routing overhead