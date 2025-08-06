# Swift Message Bus Fullstack Architecture Document

## Introduction

This document outlines the complete fullstack architecture for **Swift Message Bus**, a revolutionary event-driven architecture framework that leverages Swift's macro system to eliminate boilerplate code while maintaining type safety and achieving sub-millisecond performance. It serves as the single source of truth for framework development, integration patterns, and usage guidelines.

### Project Context and Vision

**Framework Classification**: Swift Message Bus is a foundational infrastructure framework, similar in scope to:
- **RxSwift/Combine** (reactive programming)
- **Firebase SDK** (comprehensive platform capabilities)
- **Apollo iOS** (GraphQL with code generation)

**Unique Positioning**: Unlike existing solutions, Swift Message Bus is the first to leverage Swift 5.9+ macros for compile-time code generation, creating a zero-overhead abstraction layer for event-driven architecture.

### Technical Innovation Details

**Macro System Revolution**:
- **40+ Production Macros**: From basic `@Subscribe` to advanced `@WorkflowOrchestrator`
- **Compile-Time Code Generation**: All boilerplate generated at build time, zero runtime overhead
- **Type-Safe Message Contracts**: Events, Commands, and Queries with full IDE support
- **Actor-Based Isolation**: Every component is thread-safe by default using Swift actors

**Performance Targets**:
```swift
// Benchmarked Performance Goals
- Message Throughput: 1M+ messages/second (M1 Pro)
- Latency P99: <1ms for local delivery
- Memory Overhead: <10MB for 1000 subscribers
- Startup Time: <100ms framework initialization
```

### Architecture Document Scope

This document covers three critical perspectives:

1. **Framework Architecture** - Internal design of the Swift Message Bus itself
   - Actor-based core implementation
   - Macro compilation pipeline
   - Performance optimization strategies
   - Memory management approach

2. **Integration Architecture** - How applications integrate the framework
   - Swift Package Manager distribution
   - Platform-specific implementations (iOS, macOS, watchOS, tvOS, Linux)
   - Migration paths from existing solutions
   - Interoperability with SwiftUI, UIKit, and server frameworks

3. **Extension Architecture** - Ecosystem and plugin system
   - Custom macro development guidelines
   - Third-party extension points
   - Community contribution patterns
   - Enterprise customization capabilities

### Framework Dependencies and Requirements

**Core Dependencies**:
```yaml
Swift: ">=5.9"  # Required for macro support
Platforms:
  - iOS: ">=16.0"      # Actor model optimization
  - macOS: ">=13.0"    # Full async/await support  
  - watchOS: ">=9.0"   # Reduced feature set
  - tvOS: ">=16.0"     # Full feature parity with iOS
  - Linux: "Ubuntu 22.04+"  # Server-side Swift support

Build Dependencies:
  - SwiftSyntax: "509.0.0"  # Macro implementation
  - swift-collections: "1.0.0"  # Performance data structures
  
Optional Dependencies:
  - swift-log: "1.5.0"  # Structured logging
  - swift-metrics: "2.4.0"  # Performance monitoring
  - swift-distributed-tracing: "1.0.0"  # Distributed systems
```

**Development Environment**:
```yaml
Xcode: ">=15.0"  # Required for macro debugging
Swift Toolchain: "5.9+"
SPM Tools Version: "5.9"
DocC: Integrated documentation
```

### Starter Template or Existing Project

**Framework Foundation**: Building on modern Swift infrastructure:

- **Swift Package Manager** - Native distribution and dependency management
- **SwiftSyntax** - Official Swift macro implementation framework
- **Swift Concurrency** - Actor model and async/await patterns
- **DocC** - Apple's documentation compiler for API references

**Reference Implementations Analyzed**:
- Studied **Vapor's** event system for server-side patterns
- Examined **The Composable Architecture's** dependency injection
- Reviewed **PointFree's** macro implementations for best practices
- Analyzed **Firebase iOS SDK's** modular architecture

**Package Structure**:
```
SwiftMessageBus/
├── Sources/
│   ├── SwiftMessageBus/          # Core framework
│   │   ├── Core/                 # Actor-based message bus
│   │   ├── Protocols/            # Event, Command, Query protocols
│   │   └── Extensions/           # Platform integrations
│   ├── SwiftMessageBusMacros/    # Macro implementations
│   │   ├── Subscribe/            # @Subscribe macro
│   │   ├── Publish/              # @Publish macro
│   │   └── Advanced/             # 40+ advanced macros
│   └── SwiftMessageBusClient/    # Client integration code
├── Tests/
│   ├── SwiftMessageBusTests/     # Core tests
│   ├── MacroTests/               # Macro compilation tests
│   └── PerformanceTests/        # Benchmark suite
├── Examples/
│   ├── BasicExample/             # Hello World
│   ├── SwiftUIExample/          # SwiftUI integration
│   ├── VaporExample/            # Server-side usage
│   └── EnterpriseExample/       # Full feature showcase
└── Package.swift
```

### Development Philosophy

**Core Principles**:
1. **Progressive Disclosure** - Simple things simple, complex things possible
2. **Compile-Time Safety** - Catch all errors at build time, not runtime
3. **Zero-Cost Abstractions** - Macros generate code you would write manually
4. **Platform Native** - Embrace each Apple platform's unique capabilities

### Target Environments

| Environment | Use Case | Integration Model |
|------------|----------|-------------------|
| **iOS/iPadOS Apps** | UI event coordination, state management | SwiftUI property wrappers, UIKit extensions |
| **macOS Applications** | Multi-window coordination, system events | AppKit integration, Distributed notifications |
| **watchOS Apps** | Companion app sync, complication updates | Minimal footprint, battery optimization |
| **tvOS Applications** | Focus engine coordination, remote events | Top shelf extensions, multi-user support |
| **Server-Side Swift** | Microservices communication, CQRS/ES | Vapor/Hummingbird middleware, async handlers |
| **Swift Playgrounds** | Learning and prototyping | Interactive documentation, live examples |

### Integration Examples

**SwiftUI Integration**:
```swift
// Seamless SwiftUI binding
struct ContentView: View {
    @MessageBusState var cartItems: [Item] = []
    
    var body: some View {
        List(cartItems) { item in
            ItemRow(item: item)
        }
        .onReceive(ItemAddedEvent.self) { event in
            // Auto-updates view
        }
    }
}
```

**Server-Side Integration**:
```swift
// Vapor middleware integration
app.middleware.use(MessageBusMiddleware())

app.post("order") { req in
    await req.messageBus.send(
        CreateOrderCommand(items: req.content)
    )
}
```

### Competitive Analysis Context

| Framework | Strengths | Why We're Better |
|-----------|-----------|------------------|
| **NotificationCenter** | Built-in, simple | Type-unsafe, no async support |
| **Combine** | Apple official, reactive | Complex, no macro support |
| **RxSwift** | Mature, feature-rich | Heavy, steep learning curve |
| **AsyncAlgorithms** | Modern, async-first | Not event-focused |
| **Our Solution** | Type-safe, zero-boilerplate, actor-based | First to use macros + actors |

### Change Log

| Date | Version | Description | Author |
|------|---------|-------------|---------|
| 2025-08-06 | 1.0 | Initial architecture document | Winston (Architect) |
| 2025-08-06 | 1.1 | Expanded introduction with framework context | Winston (Architect) |
| 2025-08-06 | 1.2 | Added technical details and package structure | Winston (Architect) |

### Document Usage Guidelines

**For Framework Contributors**:
- Sections 2-5 define core architecture decisions
- Section 6-8 cover implementation patterns
- Section 9+ detail testing and deployment

**For Application Developers**:
- Section 3 (Tech Stack) defines integration requirements
- Section 4 (Data Models) shows message type patterns
- Section 5 (API Spec) documents public interfaces

**For Enterprise Architects**:
- Section 7 (External APIs) covers extensibility
- Section 10 (Security/Performance) addresses compliance
- Section 11 (Monitoring) defines observability

## High Level Architecture

### Technical Summary

Swift Message Bus is a compile-time optimized, actor-based event-driven framework that transforms Swift applications through macro-powered code generation. The architecture employs a **four-layer design**:

1. **Macro Layer** - 40+ Swift macros that generate boilerplate at compile-time
2. **Core Runtime** - Actor-based message routing with sub-millisecond latency
3. **Integration Layer** - Platform-specific adapters for SwiftUI, UIKit, AppKit, and server frameworks
4. **Extension Layer** - Plugin system for domain-specific capabilities (gaming, ML, enterprise)

The framework integrates seamlessly with SwiftUI/UIKit for client applications and Vapor/Hummingbird for server deployments, using a unified API that supports Events, Commands, and Queries patterns. Through innovative use of Swift 5.9's macro system combined with structured concurrency, the architecture achieves its PRD goals of 90% boilerplate reduction, sub-millisecond latency, and complete type safety.

### Platform and Infrastructure Choice

**Multi-Tier Distribution Strategy**:

**Tier 1: Source & Package Distribution**
```yaml
Primary Repository:
  Platform: GitHub
  URL: github.com/swift-message-bus/swift-message-bus
  Features:
    - Automated releases via GitHub Actions
    - Swift Package Manager integration
    - Semantic versioning (SemVer)
    - Git LFS for benchmark data

Package Registry:
  - Swift Package Index (primary discovery)
  - CocoaPods (legacy support)
  - Carthage (optional)
  
CDN Distribution:
  - GitHub's global CDN for releases
  - Swift.org package registry (when available)
```

**Tier 2: Documentation & Learning**
```yaml
Documentation Platform:
  Primary: GitHub Pages + DocC
  URL: swiftmessagebus.dev
  Components:
    - API Reference (auto-generated via DocC)
    - Tutorials (Swift Playgrounds format)
    - Architecture Guide (this document)
    - Migration Guides (from RxSwift/Combine)
    
Interactive Learning:
  - Swift Playgrounds (downloadable)
  - Online REPL (via SwiftFiddle integration)
  - Video tutorials (YouTube channel)
```

**Tier 3: Community & Support**
```yaml
Community Platforms:
  - GitHub Discussions (Q&A, RFCs)
  - Discord Server (real-time help)
  - Stack Overflow tag (#swift-message-bus)
  - Twitter/X (@SwiftMsgBus)
  
Enterprise Support:
  - GitHub Sponsors tiers
  - Priority issue tracking
  - Private Discord channels
  - Custom macro development
```

### Repository Structure

```
swift-message-bus/
├── Package.swift                      # Root package manifest
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                    # Multi-platform CI
│   │   ├── benchmarks.yml            # Performance regression tests
│   │   ├── documentation.yml         # DocC generation
│   │   └── release.yml               # Automated releases
│   └── ISSUE_TEMPLATE/
├── Sources/
│   ├── SwiftMessageBus/              # Core Framework
│   │   ├── Core/
│   │   │   ├── MessageBusActor.swift
│   │   │   ├── MessageRouter.swift
│   │   │   └── MessageQueue.swift
│   │   ├── Protocols/
│   │   │   ├── Event.swift
│   │   │   ├── Command.swift
│   │   │   └── Query.swift
│   │   ├── Extensions/
│   │   │   ├── SwiftUI/
│   │   │   ├── UIKit/
│   │   │   └── Vapor/
│   │   └── Public/
│   │       └── MessageBus.swift      # Public API
│   ├── SwiftMessageBusMacros/        # Macro Implementations
│   │   ├── Core/
│   │   │   ├── SubscribeMacro.swift
│   │   │   ├── PublishMacro.swift
│   │   │   └── MessageBusActorMacro.swift
│   │   ├── Advanced/
│   │   │   ├── WorkflowOrchestratorMacro.swift
│   │   │   ├── StateProjectionMacro.swift
│   │   │   ├── CircuitBreakerMacro.swift
│   │   │   └── [37 more macros...]
│   │   └── MacroPlugin.swift
│   └── SwiftMessageBusClient/        # Client Runtime
│       └── MacroClient.swift
├── Tests/
│   ├── SwiftMessageBusTests/
│   │   ├── CoreTests/
│   │   ├── IntegrationTests/
│   │   └── PlatformTests/
│   ├── MacroTests/
│   │   ├── CompilationTests/
│   │   └── ExpansionTests/
│   └── PerformanceTests/
│       ├── ThroughputTests.swift
│       ├── LatencyTests.swift
│       └── MemoryTests.swift
├── Examples/
│   ├── HelloWorld/                   # Minimal example
│   ├── TodoApp/                      # SwiftUI + State management
│   ├── ChatServer/                   # Vapor + real-time
│   ├── GameEngine/                   # SpriteKit + multiplayer
│   └── EnterpriseApp/                # Full feature showcase
├── Benchmarks/
│   ├── Package.swift
│   └── Sources/
│       └── MessageBusBenchmarks/
├── Documentation/
│   ├── Articles/
│   ├── Tutorials/
│   └── Resources/
└── Scripts/
    ├── generate-docs.sh
    ├── run-benchmarks.sh
    └── validate-macros.sh
```

### High Level Architecture Diagram

```mermaid
graph TB
    subgraph "Build Time Pipeline"
        SOURCE[Source Code]
        MACRO_EXPAND[Macro Expansion<br/>40+ Macros]
        AST[AST Transformation]
        CODEGEN[Code Generation]
        TYPECHECK[Type Checking]
        OPTIMIZE[Optimization]
        BINARY[Compiled Binary]
    end
    
    subgraph "Core Architecture"
        subgraph "Message Bus Actor"
            ACTOR[Main Actor]
            QUEUE[Priority Queue]
            ROUTER[Smart Router]
            REGISTRY[Handler Registry]
        end
        
        subgraph "Message Processing"
            VALIDATE[Type Validator]
            TRANSFORM[Transformers]
            MIDDLEWARE[Middleware Chain]
            DISPATCH[Dispatcher]
        end
        
        subgraph "Storage Layer"
            MEMORY[In-Memory Store]
            PERSIST[Persistent Store<br/>Optional]
            SNAPSHOT[Snapshots]
        end
    end
    
    subgraph "Message Type System"
        subgraph "Events"
            E1[Domain Events]
            E2[System Events]
            E3[UI Events]
        end
        
        subgraph "Commands"  
            C1[Sync Commands]
            C2[Async Commands]
            C3[Saga Commands]
        end
        
        subgraph "Queries"
            Q1[Simple Queries]
            Q2[Aggregated Queries]
            Q3[Subscription Queries]
        end
    end
    
    subgraph "Platform Adapters"
        subgraph "Apple Platforms"
            IOS_ADAPT[iOS Adapter<br/>UIKit/SwiftUI]
            MAC_ADAPT[macOS Adapter<br/>AppKit/SwiftUI]
            WATCH_ADAPT[watchOS Adapter<br/>Minimal footprint]
            TV_ADAPT[tvOS Adapter]
        end
        
        subgraph "Server Platforms"
            VAPOR[Vapor Middleware]
            HUMMINGBIRD[Hummingbird Plugin]
            LAMBDA[AWS Lambda Handler]
        end
    end
    
    subgraph "Advanced Macro Features"
        M1[State Management<br/>@StateProjection]
        M2[Workflows<br/>@WorkflowOrchestrator]
        M3[Resilience<br/>@CircuitBreaker]
        M4[Performance<br/>@LoadBalancer]
        M5[Security<br/>@AuditLog]
    end
    
    SOURCE --> MACRO_EXPAND
    MACRO_EXPAND --> AST
    AST --> CODEGEN
    CODEGEN --> TYPECHECK
    TYPECHECK --> OPTIMIZE
    OPTIMIZE --> BINARY
    
    BINARY --> ACTOR
    ACTOR --> QUEUE
    QUEUE --> ROUTER
    ROUTER --> REGISTRY
    
    ROUTER --> VALIDATE
    VALIDATE --> TRANSFORM
    TRANSFORM --> MIDDLEWARE
    MIDDLEWARE --> DISPATCH
    
    DISPATCH --> E1
    DISPATCH --> C1
    DISPATCH --> Q1
    
    ACTOR --> MEMORY
    MEMORY --> PERSIST
    PERSIST --> SNAPSHOT
    
    DISPATCH --> IOS_ADAPT
    DISPATCH --> VAPOR
    
    M1 -.-> MACRO_EXPAND
    M2 -.-> MACRO_EXPAND
    M3 -.-> MACRO_EXPAND
    M4 -.-> MACRO_EXPAND
    M5 -.-> MACRO_EXPAND
    
    style MACRO_EXPAND fill:#ff9999
    style ACTOR fill:#9999ff
    style ROUTER fill:#99ff99
```

### Architectural Patterns

- **Macro-Driven Development:** 
  ```swift
  // Before: 50+ lines of boilerplate
  class OrderHandler {
      private var cancellables = Set<AnyCancellable>()
      init(bus: MessageBus) {
          bus.subscribe(OrderCreated.self) { [weak self] in
              self?.handleOrderCreated($0)
          }.store(in: &cancellables)
      }
  }
  
  // After: 3 lines with macro
  @MessageBusActor
  class OrderHandler {
      @Subscribe func handle(_ event: OrderCreated) { }
  }
  ```
  *Rationale:* 90% code reduction with zero runtime overhead

- **Actor-Based Concurrency:**
  ```swift
  actor MessageBusActor {
      private var handlers: [ObjectIdentifier: [Any]] = [:]
      private let queue = PriorityQueue<Message>()
      
      func publish<E: Event>(_ event: E) async {
          await queue.enqueue(event, priority: event.priority)
          await processQueue()
      }
  }
  ```
  *Rationale:* Guaranteed thread safety without manual synchronization

- **CQRS Pattern Implementation:**
  ```swift
  protocol Event: Message { }      // Facts that happened
  protocol Command: Message {       // Actions to perform
      associatedtype Result
  }
  protocol Query: Message {         // Information requests
      associatedtype Response
  }
  ```
  *Rationale:* Type-safe distinction between different message intents

- **Plugin Architecture:**
  ```swift
  @attached(member, names: arbitrary)
  @attached(extension, conformances: MessageBusParticipant)
  public macro CustomDomainMacro() = #externalMacro(
      module: "CommunityMacros",
      type: "CustomDomainMacro"
  )
  ```
  *Rationale:* Extensible without modifying core framework

- **Compile-Time Validation:**
  ```swift
  // Macro validates at compile time:
  // - Event types conform to Event protocol
  // - Handler signatures match event types
  // - No retain cycles in closures
  @Subscribe 
  func handle(_ event: InvalidType) { } // ❌ Compile error
  ```
  *Rationale:* Eliminate entire classes of runtime errors

- **Event Sourcing Ready:**
  ```swift
  extension MessageBus {
      func enableEventSourcing(store: EventStore) {
          // Automatic event persistence
          // Time-travel debugging
          // Event replay capabilities
      }
  }
  ```
  *Rationale:* Optional complexity for advanced use cases

- **Platform-Specific Optimizations:**
  ```swift
  #if os(iOS)
  extension MessageBus {
      func optimizeForMobile() {
          // Battery-aware scheduling
          // Background task integration
          // Memory pressure handling
      }
  }
  #endif
  ```
  *Rationale:* Respect platform constraints and capabilities

- **Zero-Cost Abstractions:**
  ```swift
  // Macro generates exactly what you'd write manually
  @Subscribe func handle(_ e: UserEvent) { }
  // Generates:
  init() {
      MessageBus.shared.subscribe(UserEvent.self, handler: handle)
  }
  ```
  *Rationale:* No performance penalty for convenience

### Performance Architecture Details

**Message Processing Pipeline**:
```
1. Message Received → Actor Queue (0.1μs)
2. Type Validation → Compile-time guaranteed (0μs)
3. Handler Lookup → O(1) HashMap (0.05μs)
4. Priority Scheduling → Binary Heap (0.1μs)
5. Handler Execution → Direct dispatch (0.2μs)
Total: <0.5μs typical latency
```

**Memory Management**:
- Weak handler references prevent retain cycles
- Automatic cleanup of expired subscriptions
- Copy-on-write for message data
- Arena allocator for high-frequency messages

## Tech Stack

This is the DEFINITIVE technology selection for the Swift Message Bus framework. This table defines exact technologies, versions, and purposes for all framework components and development tools.

### Technology Stack Table

| Category | Technology | Version | Purpose | Rationale |
|----------|------------|---------|---------|-----------|
| **Framework Language** | Swift | 5.9+ | Core framework implementation | Required for macro support, actors, async/await |
| **Macro Framework** | SwiftSyntax | 509.0.0 | Macro implementations | Official Apple library for Swift macros |
| **Concurrency Model** | Swift Actors | Native | Thread-safe message routing | Zero-cost concurrency with compile-time safety |
| **Data Structures** | swift-collections | 1.0.0 | Performance-optimized collections | Deque, OrderedSet for message queuing |
| **Package Manager** | Swift Package Manager | 5.9 | Distribution and dependencies | Native Swift ecosystem integration |
| **Documentation** | DocC | Latest | API documentation | Apple's official documentation compiler |
| **Primary Testing** | XCTest | Native | Unit and integration tests | Built-in Swift testing framework |
| **Performance Testing** | swift-benchmark | 0.1.0 | Benchmark suite | Google's benchmarking library for Swift |
| **Property Testing** | SwiftCheck | 0.12.0 | Property-based testing | Catch edge cases with generated inputs |
| **CI/CD** | GitHub Actions | Latest | Continuous integration | Multi-platform testing support |
| **Code Coverage** | swift-coverage | Native | Coverage reporting | Built into Swift toolchain |
| **Linting** | SwiftLint | 0.54.0 | Code style enforcement | Maintain consistent code quality |
| **Formatting** | swift-format | 509.0.0 | Code formatting | Apple's official formatter |
| **Logging** | swift-log | 1.5.0 | Structured logging (optional) | Standard Swift server logging |
| **Metrics** | swift-metrics | 2.4.0 | Performance metrics (optional) | Production monitoring support |
| **Tracing** | swift-distributed-tracing | 1.0.0 | Distributed tracing (optional) | Enterprise observability |
| **Minimum iOS** | iOS | 16.0+ | iOS platform support | Actor optimizations available |
| **Minimum macOS** | macOS | 13.0+ | macOS platform support | Full async/await support |
| **Minimum watchOS** | watchOS | 9.0+ | watchOS platform support | Reduced feature set |
| **Minimum tvOS** | tvOS | 16.0+ | tvOS platform support | Feature parity with iOS |
| **Linux Support** | Ubuntu | 22.04+ | Server-side Swift | Vapor/Hummingbird compatibility |
| **IDE** | Xcode | 15.0+ | Primary development | Required for macro debugging |
| **Alternative IDE** | VS Code + Swift Extension | Latest | Cross-platform development | Linux development support |

### Framework Integration Points

| Integration | Technology | Version | Purpose | Rationale |
|-------------|------------|---------|---------|-----------|
| **SwiftUI** | SwiftUI | iOS 16+ | Property wrappers, view modifiers | Modern UI framework integration |
| **UIKit** | UIKit | iOS 16+ | Extensions and adapters | Legacy app support |
| **AppKit** | AppKit | macOS 13+ | macOS native integration | Desktop application support |
| **Combine** | Combine Bridge | Native | Migration path | Smooth transition from Combine |
| **Vapor** | Vapor | 4.0+ | Server-side integration | Most popular Swift server framework |
| **Hummingbird** | Hummingbird | 1.0+ | Lightweight server option | High-performance alternative |

### Development Dependencies

| Tool | Version | Purpose | Usage |
|------|---------|---------|-------|
| **swift-syntax** | 509.0.0 | Macro compilation | Build-time only |
| **swift-argument-parser** | 1.3.0 | CLI tools | Development scripts |
| **swift-benchmark** | 0.1.0 | Performance testing | Benchmark suite |
| **SwiftCheck** | 0.12.0 | Property testing | Test edge cases |

### Optional Enterprise Extensions

| Extension | Technology | Purpose | When to Use |
|-----------|------------|---------|-------------|
| **Persistence** | SQLite/CoreData | Event store | Event sourcing patterns |
| **Networking** | URLSession/AsyncHTTPClient | Remote events | Distributed systems |
| **Serialization** | Codable/Protobuf | Message encoding | Cross-platform messaging |
| **Security** | CryptoKit | Message encryption | Sensitive data handling |

## Data Models

The Swift Message Bus framework defines core data models that form the foundation of the messaging system. These models provide type-safe contracts for communication between components.

### Core Message Protocol

**Purpose:** Base protocol that all messages must conform to, providing common functionality and type safety.

**Key Attributes:**
- `id`: UUID - Unique identifier for message tracing
- `timestamp`: Date - When the message was created
- `metadata`: MessageMetadata - Headers, correlation IDs, priority
- `source`: String? - Origin of the message (optional)

#### TypeScript Interface
```typescript
interface Message {
  id: string;
  timestamp: Date;
  metadata: MessageMetadata;
  source?: string;
}

interface MessageMetadata {
  correlationId?: string;
  causationId?: string;
  priority: MessagePriority;
  headers: Record<string, any>;
  ttl?: number; // Time to live in milliseconds
}
```

#### Relationships
- Base protocol for Event, Command, and Query
- Extended by all custom message types
- Used by MessageRouter for type-safe routing

### Event Model

**Purpose:** Represents facts that have happened in the system. Events are immutable and can have multiple subscribers.

**Key Attributes:**
- Inherits all Message attributes
- `eventType`: String - Discriminator for event routing
- `version`: Int - Schema version for evolution
- `aggregateId`: String? - Domain aggregate reference

#### TypeScript Interface
```typescript
interface Event extends Message {
  eventType: string;
  version: number;
  aggregateId?: string;
}

// Example concrete event
interface UserLoggedInEvent extends Event {
  eventType: "UserLoggedIn";
  userId: string;
  sessionId: string;
  loginMethod: "password" | "oauth" | "biometric";
}
```

#### Relationships
- Published through MessageBus.publish()
- Can have zero to many subscribers
- Stored in EventStore when event sourcing is enabled
- Used by @StateProjection for state synchronization

### Command Model

**Purpose:** Represents an intention to perform an action. Commands have a single handler and return a result.

**Key Attributes:**
- Inherits all Message attributes
- `commandType`: String - Discriminator for command routing
- `targetId`: String? - Specific target for the command
- Associated type `Result` - Type-safe return value

#### TypeScript Interface
```typescript
interface Command<TResult> extends Message {
  commandType: string;
  targetId?: string;
  // Result type is generic
}

// Example concrete command
interface CreateOrderCommand extends Command<OrderResult> {
  commandType: "CreateOrder";
  userId: string;
  items: OrderItem[];
  shippingAddress: Address;
}

interface OrderResult {
  orderId: string;
  status: "created" | "failed";
  totalAmount: number;
  estimatedDelivery?: Date;
}
```

#### Relationships
- Sent through MessageBus.send() with async result
- Exactly one handler per command type
- Can trigger saga workflows via @WorkflowOrchestrator
- May produce events as side effects

### Query Model

**Purpose:** Represents a request for information without side effects. Queries are read-only operations.

**Key Attributes:**
- Inherits all Message attributes
- `queryType`: String - Discriminator for query routing
- `filters`: QueryFilters? - Optional filtering criteria
- `pagination`: Pagination? - Optional pagination parameters
- Associated type `Response` - Type-safe response

#### TypeScript Interface
```typescript
interface Query<TResponse> extends Message {
  queryType: string;
  filters?: QueryFilters;
  pagination?: Pagination;
}

interface QueryFilters {
  conditions: FilterCondition[];
  orderBy?: OrderByClause[];
}

interface Pagination {
  offset: number;
  limit: number;
}

// Example concrete query
interface GetUserOrdersQuery extends Query<OrderListResponse> {
  queryType: "GetUserOrders";
  userId: string;
  status?: OrderStatus[];
  dateRange?: { from: Date; to: Date };
}

interface OrderListResponse {
  orders: Order[];
  totalCount: number;
  hasMore: boolean;
}
```

#### Relationships
- Executed through MessageBus.query() with async response
- Can be cached for performance optimization
- Often backed by read models/projections
- May use @EventProjector for CQRS read models

### Subscription Model

**Purpose:** Represents a handler registration for messages, managing lifecycle and type safety.

**Key Attributes:**
- `id`: UUID - Unique subscription identifier
- `messageType`: Type - Swift type of message to handle
- `handler`: AsyncHandler - Async function to process messages
- `filter`: MessageFilter? - Optional runtime filtering
- `priority`: HandlerPriority - Execution order
- `isWeak`: Bool - Weak reference to prevent cycles

#### TypeScript Interface
```typescript
interface Subscription {
  id: string;
  messageType: string; // Type name as string
  priority: HandlerPriority;
  filter?: MessageFilter;
  isWeak: boolean;
  isActive: boolean;
}

interface MessageFilter {
  predicate: (message: Message) => boolean;
  description: string; // For debugging
}

enum HandlerPriority {
  Critical = 1000,
  High = 750,
  Normal = 500,
  Low = 250,
  Background = 0
}
```

#### Relationships
- Created by @Subscribe macro at compile time
- Managed by MessageRegistry in the bus actor
- Automatically cleaned up on deallocation
- Can be paused/resumed for flow control

### MessageBusActor State

**Purpose:** Encapsulates the internal state of the message bus actor for thread-safe operations.

**Key Attributes:**
- `subscriptions`: OrderedDictionary - Type-indexed subscription storage
- `messageQueue`: PriorityQueue - Pending messages by priority
- `metrics`: BusMetrics - Performance counters
- `configuration`: BusConfiguration - Runtime settings

#### TypeScript Interface
```typescript
interface MessageBusState {
  subscriptions: Map<string, Subscription[]>;
  messageQueue: PriorityQueue<QueuedMessage>;
  metrics: BusMetrics;
  configuration: BusConfiguration;
  middleware: MiddlewareChain;
}

interface BusMetrics {
  messagesPublished: number;
  messagesProcessed: number;
  averageLatency: number;
  errorCount: number;
  subscriptionCount: number;
}

interface BusConfiguration {
  maxQueueSize: number;
  processingTimeout: number;
  enableMetrics: boolean;
  enableTracing: boolean;
  logLevel: LogLevel;
}
```

#### Relationships
- Internal to MessageBusActor
- Modified only through actor-isolated methods
- Observed by monitoring/metrics systems
- Snapshot-able for debugging

### Workflow State Model

**Purpose:** Represents the state of a workflow orchestration for complex multi-step processes.

**Key Attributes:**
- `workflowId`: UUID - Unique workflow instance
- `definition`: WorkflowDefinition - Steps and transitions
- `currentState`: String - Active state in the workflow
- `context`: WorkflowContext - Shared workflow data
- `history`: [StateTransition] - Audit trail

#### TypeScript Interface
```typescript
interface WorkflowState {
  workflowId: string;
  definition: WorkflowDefinition;
  currentState: string;
  context: WorkflowContext;
  history: StateTransition[];
  startedAt: Date;
  completedAt?: Date;
}

interface WorkflowDefinition {
  name: string;
  version: number;
  states: WorkflowStateNode[];
  transitions: StateTransition[];
  timeouts: TimeoutPolicy[];
  compensations: CompensationPolicy[];
}

interface WorkflowContext {
  variables: Record<string, any>;
  correlationId: string;
  parentWorkflowId?: string;
}
```

#### Relationships
- Created by @WorkflowOrchestrator macro
- Persisted for long-running workflows
- Can spawn child workflows
- Supports saga pattern with compensations

## API Specification

The Swift Message Bus framework provides a fully type-safe API with **Swift 6 strict concurrency compliance**. Every operation is strongly typed with compile-time guarantees and zero runtime casting.

### Core Design Principles

```swift
// ✅ EVERY operation is type-safe at compile time
// ✅ NO stringly-typed APIs or runtime casting
// ✅ Full Swift 6 concurrency compliance
// ✅ All types are Sendable
// ✅ Structured concurrency throughout
```

### Core MessageBus API

```swift
// MARK: - Main MessageBus Actor
@globalActor
public actor MessageBus: Sendable {
    
    // MARK: - Initialization
    
    /// Create a new message bus instance
    public init(configuration: BusConfiguration = .default)
    
    /// Shared instance (optional - not required)
    @MessageBus 
    public static let shared = MessageBus()
    
    // MARK: - Event Publishing (One-to-Many)
    
    /// Publish an event - Multiple handlers can receive it
    /// - Parameter event: A concrete event type (not a protocol)
    /// - Returns: Number of handlers that processed the event
    @discardableResult
    public func publish<E: Event>(_ event: E) async -> Int where E: Sendable
    
    // Example usage:
    // let event = UserLoggedInEvent(userId: "123", timestamp: .now)
    // await messageBus.publish(event)  // Type is UserLoggedInEvent, not Event
    
    // MARK: - Command Sending (One-to-One with Result)
    
    /// Send a command - Exactly one handler, returns a specific result type
    /// - Parameter command: A concrete command with associated Result type
    /// - Returns: The specific Result type defined by the command
    /// - Throws: If no handler exists or execution fails
    public func send<C: Command>(_ command: C) async throws -> C.Result 
        where C: Sendable, C.Result: Sendable
    
    // Example usage:
    // let command = CreateOrderCommand(items: items)
    // let result: OrderCreatedResult = try await messageBus.send(command)
    // print(result.orderId)  // Fully typed, no casting
    
    // MARK: - Query Execution (Request-Response with Specific Type)
    
    /// Execute a query - Returns a specific response type
    /// - Parameter query: A concrete query with associated Response type
    /// - Returns: The specific Response type defined by the query
    /// - Throws: If no handler exists or query fails
    public func query<Q: Query>(_ query: Q) async throws -> Q.Response
        where Q: Sendable, Q.Response: Sendable
    
    // Example usage:
    // let query = GetUserOrdersQuery(userId: "123")
    // let orders: [Order] = try await messageBus.query(query)
    // orders.forEach { print($0.id) }  // Fully typed array of Order
    
    // MARK: - Subscription (Type-Safe Handlers)
    
    /// Subscribe to a specific message type
    /// - Parameters:
    ///   - type: The concrete message type (not protocol)
    ///   - handler: Function that receives the specific type
    /// - Returns: Subscription for lifecycle management
    public func subscribe<M: Message>(
        to type: M.Type,
        priority: HandlerPriority = .normal,
        handler: @Sendable @escaping (M) async -> Void
    ) -> Subscription where M: Sendable
    
    // Example usage:
    // let subscription = messageBus.subscribe(to: OrderCreatedEvent.self) { event in
    //     print(event.orderId)  // event is OrderCreatedEvent, not Message
    // }
}
```

### Message Protocols - Clear Type Relationships

```swift
// MARK: - Base Message Protocol
public protocol Message: Sendable {
    var id: UUID { get }
    var timestamp: Date { get }
    var metadata: MessageMetadata { get }
}

// MARK: - Event Protocol (Facts that Happened)
public protocol Event: Message {
    static var eventType: String { get }
}

// MARK: - Command Protocol (Actions with Results)
public protocol Command: Message {
    /// The specific type returned when this command succeeds
    associatedtype Result: Sendable
    static var commandType: String { get }
}

// MARK: - Query Protocol (Questions with Answers)
public protocol Query: Message {
    /// The specific type returned as the answer
    associatedtype Response: Sendable
    static var queryType: String { get }
}
```

### Concrete Examples - See the Type Safety

```swift
// MARK: - Event Example
public struct UserLoggedInEvent: Event {
    // Event protocol requirements
    public static let eventType = "UserLoggedIn"
    
    // Message protocol requirements
    public let id = UUID()
    public let timestamp = Date()
    public let metadata = MessageMetadata.default
    
    // Event-specific data (strongly typed)
    public let userId: String
    public let sessionId: String
    public let ipAddress: String
    public let userAgent: String
}

// MARK: - Command Example with Specific Result Type
public struct CreateOrderCommand: Command {
    // This command returns OrderCreatedResult specifically
    public typealias Result = OrderCreatedResult
    
    // Command protocol requirements
    public static let commandType = "CreateOrder"
    
    // Message protocol requirements
    public let id = UUID()
    public let timestamp = Date()
    public let metadata = MessageMetadata.default
    
    // Command-specific data (strongly typed)
    public let userId: String
    public let items: [OrderItem]
    public let shippingAddress: Address
    public let paymentMethod: PaymentMethod
}

// The specific result type for CreateOrderCommand
public struct OrderCreatedResult: Sendable {
    public let orderId: String
    public let estimatedDelivery: Date
    public let totalAmount: Decimal
    public let trackingNumber: String
}

// MARK: - Query Example with Specific Response Type
public struct GetUserOrdersQuery: Query {
    // This query returns an array of Order specifically
    public typealias Response = [Order]
    
    // Query protocol requirements
    public static let queryType = "GetUserOrders"
    
    // Message protocol requirements
    public let id = UUID()
    public let timestamp = Date()
    public let metadata = MessageMetadata.default
    
    // Query-specific parameters (strongly typed)
    public let userId: String
    public let status: OrderStatus?
    public let limit: Int
    public let offset: Int
}

// Another query with different response type
public struct GetOrderStatsQuery: Query {
    // This query returns OrderStatistics specifically
    public typealias Response = OrderStatistics
    
    public static let queryType = "GetOrderStats"
    
    // Message requirements...
    public let id = UUID()
    public let timestamp = Date()
    public let metadata = MessageMetadata.default
    
    // Query parameters
    public let startDate: Date
    public let endDate: Date
}

// The specific response type for GetOrderStatsQuery
public struct OrderStatistics: Sendable {
    public let totalOrders: Int
    public let totalRevenue: Decimal
    public let averageOrderValue: Decimal
    public let topProducts: [Product]
    public let ordersByDay: [Date: Int]
}
```

### Usage Examples - Complete Type Safety

```swift
// MARK: - Publishing Events
@MessageBusActor
class AuthenticationService {
    func login(username: String, password: String) async throws {
        // ... authentication logic ...
        
        // Publish a strongly-typed event
        let event = UserLoggedInEvent(
            userId: user.id,
            sessionId: session.id,
            ipAddress: request.ip,
            userAgent: request.userAgent
        )
        
        await messageBus.publish(event)  // event is UserLoggedInEvent
    }
}

// MARK: - Sending Commands with Typed Results
@MessageBusActor
class OrderController {
    func createOrder(items: [OrderItem]) async throws -> OrderCreatedResult {
        let command = CreateOrderCommand(
            userId: currentUser.id,
            items: items,
            shippingAddress: currentUser.defaultAddress,
            paymentMethod: currentUser.defaultPayment
        )
        
        // Returns OrderCreatedResult specifically, not Any or generic Result
        let result = try await messageBus.send(command)
        
        // Can access all properties with full type safety
        print("Order \(result.orderId) created")
        print("Delivery on \(result.estimatedDelivery)")
        print("Total: \(result.totalAmount)")
        
        return result  // Return type is OrderCreatedResult
    }
}

// MARK: - Executing Queries with Typed Responses
@MessageBusActor
class OrderViewController {
    func loadUserOrders() async throws {
        let query = GetUserOrdersQuery(
            userId: currentUser.id,
            status: .active,
            limit: 20,
            offset: 0
        )
        
        // Returns [Order] specifically, not Any or generic Response
        let orders: [Order] = try await messageBus.query(query)
        
        // Can iterate with full type safety
        for order in orders {
            print("\(order.id): \(order.totalAmount)")  // All typed
        }
    }
    
    func loadStatistics() async throws {
        let query = GetOrderStatsQuery(
            startDate: .monthAgo,
            endDate: .now
        )
        
        // Returns OrderStatistics specifically
        let stats: OrderStatistics = try await messageBus.query(query)
        
        // Access all properties with full type safety
        print("Total orders: \(stats.totalOrders)")
        print("Revenue: \(stats.totalRevenue)")
        print("Average: \(stats.averageOrderValue)")
        
        // Even nested types are fully typed
        for product in stats.topProducts {
            print("\(product.name): \(product.salesCount)")
        }
    }
}

// MARK: - Subscribing with Type Safety
@MessageBusActor
class InventoryService {
    func setupSubscriptions() {
        // Subscribe to specific event type
        messageBus.subscribe(to: OrderCreatedEvent.self) { event in
            // event is OrderCreatedEvent, not generic Event
            await self.updateInventory(
                items: event.items,  // Fully typed access
                orderId: event.orderId
            )
        }
        
        // Subscribe to specific command type
        messageBus.subscribe(to: UpdateInventoryCommand.self) { command in
            // command is UpdateInventoryCommand, not generic Command
            let result = await self.processUpdate(
                productId: command.productId,  // Fully typed
                quantity: command.quantity
            )
            return result  // Returns UpdateInventoryCommand.Result type
        }
    }
}
```

### Handler Registration - Type-Safe at Compile Time

```swift
// MARK: - Command Handler Registration
extension MessageBus {
    /// Register a command handler with compile-time type checking
    public func handle<C: Command>(
        command type: C.Type,
        handler: @Sendable @escaping (C) async throws -> C.Result
    ) where C: Sendable, C.Result: Sendable {
        // Handler must return exactly C.Result type
        // Compile error if types don't match
    }
}

// Usage - Types must match exactly
messageBus.handle(command: CreateOrderCommand.self) { command in
    // Must return OrderCreatedResult, not any other type
    let order = await createOrder(command.items)
    return OrderCreatedResult(
        orderId: order.id,
        estimatedDelivery: order.estimatedDelivery,
        totalAmount: order.total,
        trackingNumber: order.tracking
    )
    // return "success"  // ❌ Compile error - wrong type
}

// MARK: - Query Handler Registration
extension MessageBus {
    /// Register a query handler with compile-time type checking
    public func handle<Q: Query>(
        query type: Q.Type,
        handler: @Sendable @escaping (Q) async throws -> Q.Response
    ) where Q: Sendable, Q.Response: Sendable {
        // Handler must return exactly Q.Response type
    }
}

// Usage - Response type must match
messageBus.handle(query: GetUserOrdersQuery.self) { query in
    // Must return [Order], not any other type
    let orders = await database.fetchOrders(
        userId: query.userId,
        status: query.status
    )
    return orders  // Type is [Order]
    // return ["order1", "order2"]  // ❌ Compile error - wrong type
}

messageBus.handle(query: GetOrderStatsQuery.self) { query in
    // Must return OrderStatistics, not any other type
    let stats = await analytics.calculate(
        from: query.startDate,
        to: query.endDate
    )
    return stats  // Type is OrderStatistics
    // return 42  // ❌ Compile error - wrong type
}
```

### SwiftUI Integration - Type-Safe UI Updates

```swift
// MARK: - SwiftUI View with Type-Safe Message Bus
struct OrderListView: View {
    // Type-safe state that updates from events
    @MessageBusState var orders: [Order] = []
    @MessageBusState var statistics: OrderStatistics?
    
    var body: some View {
        List(orders) { order in  // orders is [Order], fully typed
            OrderRow(
                id: order.id,
                total: order.totalAmount,
                status: order.status
            )
        }
        .task {
            // Load orders with type safety
            let query = GetUserOrdersQuery(
                userId: currentUser.id,
                status: nil,
                limit: 50,
                offset: 0
            )
            
            orders = try await messageBus.query(query)  // Returns [Order]
        }
        .onReceive(OrderCreatedEvent.self) { event in
            // event is OrderCreatedEvent, not generic Event
            orders.append(event.toOrder())  // Fully typed
        }
    }
}
```

### Why This Type Safety Matters

```swift
// ❌ WITHOUT Type Safety (Other Frameworks)
let result = try await bus.send("CreateOrder", data: ["items": items])
let orderId = result["orderId"] as? String  // Runtime casting, could fail
let total = result["total"] as? Decimal  // More runtime casting

// ✅ WITH Our Type Safety
let result = try await messageBus.send(CreateOrderCommand(items: items))
let orderId = result.orderId  // Compile-time guaranteed String
let total = result.totalAmount  // Compile-time guaranteed Decimal

// The compiler ensures:
// 1. CreateOrderCommand always returns OrderCreatedResult
// 2. OrderCreatedResult always has orderId: String
// 3. No runtime crashes from type mismatches
// 4. Full IDE autocomplete for all properties
```