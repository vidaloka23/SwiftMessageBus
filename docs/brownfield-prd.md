# Brownfield PRD: Swift Message Bus MVP Implementation

## Executive Summary

**Current State**: The Swift Message Bus project has comprehensive documentation (brief.md, architecture.md) defining a revolutionary event-driven framework for Swift. However, no actual code implementation exists yet. The project consists entirely of planning documents and the BMad framework structure.

**Target State**: Implement a working MVP of the Swift Message Bus framework that validates the core concept: actor-based messaging with type-safe macros achieving sub-millisecond latency and 90% boilerplate reduction.

**Enhancement Scope**: Transform the documented architecture into a functional Swift Package with core messaging capabilities, essential macros (@Subscribe, @MessageBusActor, @Event, @Command, @Query), and a comprehensive benchmark suite proving performance claims.

## Context & Background

### Existing Documentation Analysis

**What We Have**:
- **Project Brief** (brief.md): 425 lines defining the vision, market opportunity, and 40+ planned macros
- **Architecture Document** (architecture.md): 1,389 lines detailing the complete technical design
- **BMad Framework**: Agent-based development methodology structure (not actual Swift code)

**What's Missing**:
- Any Swift source code
- Package.swift manifest
- Macro implementations
- Test suite
- Benchmark suite
- Example applications
- CI/CD pipeline

### Critical Path to MVP

Based on the brief's MVP scope (lines 267-346), we need to implement:

1. **Core Message Bus Actor** (Weeks 1-2)
2. **Essential Macros** (Weeks 3-4)  
3. **Benchmarking Suite** (Weeks 5-6)

This PRD focuses on achieving the POC success criteria from the brief:
- 100K+ messages/second on M1 Mac
- <1ms p99 latency
- <5MB memory overhead
- Working example in <3 minutes

## Enhancement Requirements

### Functional Requirements

#### FR1: Core Actor-Based Message Bus
**Priority**: P0 - Critical

Create the foundational `MessageBusActor` that manages all message routing:

```swift
// Required capabilities from architecture.md lines 964-1036
- publish<E: Event>(_ event: E) async -> Int
- send<C: Command>(_ command: C) async throws -> C.Result
- query<Q: Query>(_ query: Q) async throws -> Q.Response
- subscribe<M: Message>(to: M.Type, handler: @Sendable @escaping (M) async -> Void)
```

**Acceptance Criteria**:
- Thread-safe message routing using Swift actors
- Type-safe message handling without any stringly-typed APIs
- Support for Events (one-to-many), Commands (one-to-one), and Queries (request-response)
- Zero locks, zero race conditions

#### FR2: Message Type System Implementation
**Priority**: P0 - Critical

Implement the protocol hierarchy defined in architecture.md (lines 1038-1066):

```swift
- Message protocol with id, timestamp, metadata
- Event protocol for facts that happened
- Command protocol with associated Result type
- Query protocol with associated Response type
```

**Acceptance Criteria**:
- All protocols are Sendable for Swift 6 concurrency
- Compile-time type safety for all message operations
- Full IDE autocomplete support

#### FR3: Essential Macro Implementation
**Priority**: P0 - Critical

Implement the Phase 1 macros from brief.md (lines 288-293):

```swift
@Subscribe       // Auto-register handlers with type safety
@MessageBusActor // Mark classes as message bus participants
@Event          // Message type marker
@Command        // Command type marker with Result
@Query          // Query type marker with Response
```

**Acceptance Criteria**:
- Macros generate equivalent hand-written code
- Generated code is visible for debugging
- Compile-time validation of all types
- Zero runtime overhead from macro usage

#### FR4: Benchmark Suite
**Priority**: P0 - Critical

Implement comprehensive benchmarks proving performance claims:

```swift
// From brief.md lines 294-299
- Message throughput (messages/second)
- Latency percentiles (p50, p95, p99, p99.9)
- Memory usage profiling
- Comparison with NotificationCenter, Combine
```

**Acceptance Criteria**:
- Achieve 100K+ messages/second on M1 Mac
- Sub-millisecond p99 latency
- Memory overhead <5MB for typical usage
- Automated benchmark regression testing

#### FR5: Hello World Example
**Priority**: P1 - High

Create minimal working example demonstrating core capabilities:

```swift
// User can go from zero to working in <3 minutes
- Simple event publishing
- Command with result
- Query with response
- @Subscribe macro usage
```

**Acceptance Criteria**:
- Complete example in single file
- Clear comments explaining each concept
- Runs without additional setup
- Demonstrates type safety benefits

### Non-Functional Requirements

#### NFR1: Performance Requirements
**Priority**: P0 - Critical

From brief.md performance targets:
- **Throughput**: 100K+ messages/second (MVP), 1M+ (future)
- **Latency**: <1ms p99 for local delivery
- **Memory**: <5MB overhead for 1000 subscribers
- **Startup**: <100ms framework initialization

#### NFR2: Developer Experience
**Priority**: P0 - Critical

- Installation via Swift Package Manager in one line
- Working example in <3 minutes
- Clear compile-time error messages
- Full Xcode autocomplete support

#### NFR3: Platform Support
**Priority**: P1 - High

From architecture.md platform requirements:
- iOS 16+
- macOS 13+
- Swift 5.9+ (macro support required)
- Xcode 15+ (macro debugging)

## Technical Approach

### Implementation Strategy

#### Phase 1: Core Foundation (Week 1-2)
1. Create Package.swift with proper structure
2. Implement base Message, Event, Command, Query protocols
3. Build MessageBusActor with basic publish/subscribe
4. Add type-safe handler registry

#### Phase 2: Macro System (Week 3-4)
1. Set up SwiftSyntax dependency
2. Implement @Subscribe macro
3. Add @MessageBusActor macro
4. Create message type markers (@Event, @Command, @Query)

#### Phase 3: Performance & Polish (Week 5-6)
1. Build benchmark suite using swift-benchmark
2. Optimize hot paths identified by profiling
3. Create Hello World example
4. Write initial documentation

### File Structure to Create

```
SwiftMessageBus/
├── Package.swift
├── Sources/
│   ├── SwiftMessageBus/
│   │   ├── Core/
│   │   │   ├── MessageBusActor.swift       # Main actor implementation
│   │   │   ├── MessageRegistry.swift       # Type-safe handler storage
│   │   │   └── MessageQueue.swift          # Priority queue for messages
│   │   ├── Protocols/
│   │   │   ├── Message.swift               # Base protocol
│   │   │   ├── Event.swift                 # Event protocol
│   │   │   ├── Command.swift               # Command with Result
│   │   │   └── Query.swift                 # Query with Response
│   │   └── Public/
│   │       └── MessageBus.swift            # Public API surface
│   ├── SwiftMessageBusMacros/
│   │   ├── SubscribeMacro.swift           # @Subscribe implementation
│   │   ├── MessageBusActorMacro.swift     # @MessageBusActor
│   │   ├── MessageTypeMacros.swift        # @Event, @Command, @Query
│   │   └── MacroPlugin.swift              # Macro registration
│   └── SwiftMessageBusClient/
│       └── MacroClient.swift               # Client-side macro support
├── Tests/
│   ├── SwiftMessageBusTests/
│   │   ├── CoreTests.swift                # Core functionality tests
│   │   └── TypeSafetyTests.swift          # Compile-time type tests
│   └── MacroTests/
│       └── MacroExpansionTests.swift      # Macro expansion tests
├── Benchmarks/
│   └── MessageBusBenchmarks.swift         # Performance benchmarks
└── Examples/
    └── HelloWorld/
        └── main.swift                      # Simple working example
```

### Dependencies

From architecture.md tech stack (lines 597-627):
```yaml
Core:
  - SwiftSyntax: "509.0.0"      # For macro implementation
  - swift-collections: "1.0.0"   # For OrderedSet, Deque

Development:
  - swift-benchmark: "0.1.0"     # For performance testing
  - XCTest: Built-in             # For unit tests
```

## Success Criteria

### MVP Delivery Checklist

- [ ] Core MessageBusActor implementation complete
- [ ] All 5 essential macros working
- [ ] Type safety verified with no runtime casting
- [ ] Benchmarks show 100K+ msgs/sec
- [ ] P99 latency <1ms confirmed
- [ ] Memory overhead <5MB validated
- [ ] Hello World example runs in <3 min
- [ ] Package.swift properly configured
- [ ] Basic tests passing
- [ ] README with quick start guide

### Validation Metrics

1. **Performance Validation**:
   - Run benchmark suite on M1 Mac
   - Compare against NotificationCenter baseline
   - Document latency percentiles

2. **Developer Experience Validation**:
   - Time new developer from install to working code
   - Verify autocomplete in Xcode
   - Test error message clarity

3. **Type Safety Validation**:
   - Attempt common type mismatches
   - Verify compile-time catching
   - No runtime type assertions needed

## Implementation Priorities

### Must Have (Week 1-6)
1. MessageBusActor core
2. Type-safe protocols
3. @Subscribe macro
4. Basic benchmarks
5. Hello World example

### Should Have (Post-MVP)
1. @MessageBusActor macro
2. Message type markers
3. Advanced benchmarks
4. SwiftUI integration example

### Could Have (Future)
1. Remaining 35+ macros
2. Persistence layer
3. Distributed messaging
4. Visual debugger

## Risk Assessment

### Technical Risks

1. **Macro Complexity**
   - Risk: SwiftSyntax learning curve
   - Mitigation: Start with simplest @Subscribe macro
   - Fallback: Manual registration API if macros delayed

2. **Performance Goals**
   - Risk: Actor overhead prevents sub-millisecond latency
   - Mitigation: Profile early and often
   - Fallback: Document realistic performance characteristics

3. **Type Safety Complexity**
   - Risk: Generic constraints become unwieldy
   - Mitigation: Start with concrete types, generalize carefully
   - Fallback: Provide both generic and concrete APIs

## Migration Notes

### From Documentation to Code

Key sections from existing docs to implement:
1. **Message Protocols**: architecture.md lines 1038-1066
2. **Core API**: architecture.md lines 964-1036  
3. **Concrete Examples**: architecture.md lines 1069-1161
4. **Handler Registration**: architecture.md lines 1274-1333

### Not in Scope for MVP

From the 40+ planned macros, these are deferred:
- @WorkflowOrchestrator
- @StateProjection
- @CircuitBreaker
- All enterprise features
- All gaming macros
- Persistence layer
- Cross-process communication

## Next Steps

1. **Immediate Actions**:
   - Create GitHub repository
   - Initialize Swift package structure
   - Implement Message protocol hierarchy
   - Begin MessageBusActor development

2. **Week 1 Deliverables**:
   - Working message publish/subscribe
   - Type-safe handler registry
   - Basic unit tests

3. **Week 2 Deliverables**:
   - Command/Query implementation
   - Performance optimizations
   - Initial benchmarks

This PRD bridges the gap between the comprehensive vision in the existing documentation and a working MVP that proves the core concept. The focus is on validating the fundamental promise: type-safe, macro-enhanced messaging with exceptional performance.