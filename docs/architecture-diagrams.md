# Swift Message Bus - Technical Architecture Diagrams

## Table of Contents
1. [System Overview](#system-overview)
2. [Core Architecture](#core-architecture)
3. [Message Flow](#message-flow)
4. [Macro Compilation Pipeline](#macro-compilation-pipeline)
5. [Actor Concurrency Model](#actor-concurrency-model)
6. [CQRS/Event Sourcing Architecture](#cqrsevent-sourcing-architecture)
7. [Performance Architecture](#performance-architecture)
8. [Deployment Architecture](#deployment-architecture)

## System Overview

```mermaid
graph TB
    subgraph "Developer Code"
        UC[User Code with Macros]
        UC --> |"@Subscribe"| M1[Event Handlers]
        UC --> |"@Command"| M2[Command Handlers]
        UC --> |"@Query"| M3[Query Handlers]
    end
    
    subgraph "Compile Time"
        MC[Macro Compiler]
        MC --> GC[Generated Code]
        GC --> TC[Type Checking]
    end
    
    subgraph "Runtime"
        MB[MessageBusActor]
        MB --> ER[Event Router]
        MB --> CR[Command Router]
        MB --> QR[Query Router]
        
        ER --> S1[Subscriber 1]
        ER --> S2[Subscriber 2]
        ER --> S3[Subscriber N]
        
        CR --> CH[Command Handler]
        QR --> QH[Query Handler]
    end
    
    UC --> MC
    TC --> MB
    
    style UC fill:#e1f5fe
    style MB fill:#fff3e0
    style MC fill:#f3e5f5
```

## Core Architecture

### Layered Architecture Design

```mermaid
graph TD
    subgraph "Application Layer"
        APP[Swift Application]
    end
    
    subgraph "Macro Layer"
        M1[@Subscribe Macro]
        M2[@Publish Macro]
        M3[@StateProjection Macro]
        M4[@WorkflowOrchestrator Macro]
        M5[40+ Other Macros]
    end
    
    subgraph "Core API Layer"
        API[Message Bus API]
        EVT[Event Protocol]
        CMD[Command Protocol]
        QRY[Query Protocol]
    end
    
    subgraph "Runtime Engine"
        ACTOR[MessageBusActor]
        ROUTER[Message Router]
        STORE[Event Store]
        PROJ[Projections]
    end
    
    subgraph "Platform Integration"
        SWIFT[Swift Concurrency]
        SWIFTUI[SwiftUI Bindings]
        COMBINE[Combine Bridge]
        UIKIT[UIKit Support]
    end
    
    APP --> M1
    APP --> M2
    APP --> M3
    APP --> M4
    APP --> M5
    
    M1 --> API
    M2 --> API
    M3 --> API
    M4 --> API
    M5 --> API
    
    API --> ACTOR
    ACTOR --> ROUTER
    ROUTER --> STORE
    ROUTER --> PROJ
    
    ACTOR --> SWIFT
    API --> SWIFTUI
    API --> COMBINE
    API --> UIKIT
    
    style APP fill:#e8f5e9
    style ACTOR fill:#fff9c4
    style API fill:#e3f2fd
```

## Message Flow

### Event Publishing Flow

```mermaid
sequenceDiagram
    participant App as Application
    participant Macro as @Publish Macro
    participant Bus as MessageBusActor
    participant Router as Event Router
    participant Sub1 as Subscriber 1
    participant Sub2 as Subscriber 2
    participant Store as Event Store
    
    App->>Macro: @Publish UserLoggedIn
    Macro->>Macro: Generate type-safe code
    Macro->>Bus: await publish(event)
    Bus->>Bus: Validate event type
    Bus->>Store: Persist event
    Bus->>Router: Route to subscribers
    
    par Parallel Delivery
        Router->>Sub1: handleUserLogin(event)
        and
        Router->>Sub2: onUserLogin(event)
    end
    
    Sub1-->>Router: Acknowledgment
    Sub2-->>Router: Acknowledgment
    Router-->>Bus: Delivery complete
    Bus-->>App: Success
```

### Command Processing Flow

```mermaid
sequenceDiagram
    participant App as Application
    participant Bus as MessageBusActor
    participant Val as Validator
    participant Handler as Command Handler
    participant Store as Event Store
    participant Proj as Projections
    
    App->>Bus: send(CreateOrderCommand)
    Bus->>Val: Validate command
    Val-->>Bus: Valid ✓
    Bus->>Handler: Process command
    Handler->>Handler: Business logic
    Handler->>Store: Store events
    Handler->>Proj: Update projections
    Handler-->>Bus: OrderCreated result
    Bus-->>App: Return result
    
    Note over Store,Proj: Transactional boundary
```

### Query Execution Flow

```mermaid
sequenceDiagram
    participant App as Application
    participant Bus as MessageBusActor
    participant Cache as Query Cache
    participant Handler as Query Handler
    participant Proj as Read Model
    
    App->>Bus: query(GetOrdersQuery)
    Bus->>Cache: Check cache
    
    alt Cache Hit
        Cache-->>Bus: Cached result
        Bus-->>App: Return cached data
    else Cache Miss
        Bus->>Handler: Execute query
        Handler->>Proj: Read from projection
        Proj-->>Handler: Data
        Handler-->>Bus: Query result
        Bus->>Cache: Update cache
        Bus-->>App: Return result
    end
```

## Macro Compilation Pipeline

### Macro Expansion Process

```mermaid
graph LR
    subgraph "Source Code"
        SC[["@Subscribe
        func handle(event) {}"]]
    end
    
    subgraph "Macro Expansion"
        P1[Parse AST]
        P2[Validate Types]
        P3[Generate Registration]
        P4[Generate Boilerplate]
        
        P1 --> P2
        P2 --> P3
        P3 --> P4
    end
    
    subgraph "Generated Code"
        GC[["private func register() {
            bus.subscribe(
                UserEvent.self,
                handler: handle
            )
        }"]]
    end
    
    subgraph "Compilation"
        TC[Type Check]
        OPT[Optimize]
        BIN[Binary]
        
        TC --> OPT
        OPT --> BIN
    end
    
    SC --> P1
    P4 --> GC
    GC --> TC
    
    style SC fill:#e8eaf6
    style GC fill:#e0f2f1
    style BIN fill:#fce4ec
```

### Advanced Macro Generation

```mermaid
graph TD
    subgraph "@WorkflowOrchestrator Macro"
        WF[Workflow Definition]
        WF --> SM[State Machine Generation]
        WF --> EH[Error Handlers]
        WF --> CMP[Compensation Logic]
        WF --> TM[Timeout Management]
        
        SM --> FSM[Finite State Machine]
        EH --> RB[Rollback Code]
        CMP --> SAGA[Saga Pattern]
        TM --> TIMER[Timer Actors]
    end
    
    subgraph "Generated Infrastructure"
        FSM --> CODE1[State Transition Code]
        RB --> CODE2[Error Recovery Code]
        SAGA --> CODE3[Compensation Code]
        TIMER --> CODE4[Timeout Code]
    end
    
    style WF fill:#f3e5f5
    style CODE1 fill:#e8f5e9
    style CODE2 fill:#ffe0b2
    style CODE3 fill:#ffecb3
    style CODE4 fill:#f0f4c3
```

## Actor Concurrency Model

### Actor-Based Message Bus

```mermaid
graph TB
    subgraph "Main Actor"
        UI[UI Updates]
    end
    
    subgraph "MessageBusActor"
        MB[Message Bus Core]
        Q1[Message Queue]
        RT[Routing Table]
        SUB[Subscribers Map]
    end
    
    subgraph "Handler Actors"
        H1[Handler Actor 1]
        H2[Handler Actor 2]
        H3[Handler Actor 3]
    end
    
    subgraph "Worker Actors"
        W1[Worker Pool 1]
        W2[Worker Pool 2]
    end
    
    UI -.->|async| MB
    MB -->|isolate| Q1
    MB -->|isolate| RT
    MB -->|isolate| SUB
    
    MB ==>|async| H1
    MB ==>|async| H2
    MB ==>|async| H3
    
    H1 -->|delegate| W1
    H2 -->|delegate| W2
    
    style MB fill:#fff3e0
    style UI fill:#e1f5fe
    style H1 fill:#f1f8e9
    style H2 fill:#f1f8e9
    style H3 fill:#f1f8e9
```

### Concurrency Safety Model

```mermaid
stateDiagram-v2
    [*] --> Idle
    
    Idle --> Processing: Receive Message
    Processing --> Routing: Validate Type
    Routing --> Dispatching: Find Handlers
    
    Dispatching --> Parallel: Multiple Handlers
    Parallel --> Handler1: Async Task
    Parallel --> Handler2: Async Task
    Parallel --> HandlerN: Async Task
    
    Handler1 --> Collecting: Complete
    Handler2 --> Collecting: Complete
    HandlerN --> Collecting: Complete
    
    Collecting --> Aggregating: All Complete
    Aggregating --> Complete: Return Result
    Complete --> Idle: Ready
    
    Processing --> Error: Validation Failed
    Error --> Idle: Log & Continue
    
    note right of Parallel
        All handlers run
        in isolation
        (actor-safe)
    end note
```

## CQRS/Event Sourcing Architecture

### CQRS Pattern Implementation

```mermaid
graph TB
    subgraph "Write Side"
        CMD[Commands]
        CMDH[Command Handlers]
        AGG[Aggregates]
        ES[Event Store]
        
        CMD --> CMDH
        CMDH --> AGG
        AGG --> ES
    end
    
    subgraph "Event Bus"
        EB[Event Stream]
        ES --> EB
    end
    
    subgraph "Read Side"
        PROJ1[Order Projections]
        PROJ2[User Projections]
        PROJ3[Analytics Projections]
        
        EB --> PROJ1
        EB --> PROJ2
        EB --> PROJ3
    end
    
    subgraph "Query Side"
        Q[Queries]
        QH[Query Handlers]
        RM[Read Models]
        
        Q --> QH
        QH --> RM
        PROJ1 --> RM
        PROJ2 --> RM
        PROJ3 --> RM
    end
    
    style CMD fill:#ffebee
    style Q fill:#e3f2fd
    style EB fill:#fff9c4
```

### Event Sourcing Flow

```mermaid
graph LR
    subgraph "Event Generation"
        E1[OrderCreated]
        E2[ItemAdded]
        E3[PaymentProcessed]
        E4[OrderShipped]
    end
    
    subgraph "Event Store"
        STREAM[Event Stream]
        SNAP[Snapshots]
    end
    
    subgraph "Projections"
        CP[Current State]
        HP[Historical View]
        AP[Analytics View]
    end
    
    subgraph "Time Travel"
        REPLAY[Event Replay]
        REBUILD[State Rebuild]
    end
    
    E1 --> STREAM
    E2 --> STREAM
    E3 --> STREAM
    E4 --> STREAM
    
    STREAM --> CP
    STREAM --> HP
    STREAM --> AP
    
    STREAM --> SNAP
    SNAP --> REPLAY
    REPLAY --> REBUILD
    
    style E1 fill:#e8f5e9
    style E2 fill:#e0f7fa
    style E3 fill:#fff3e0
    style E4 fill:#fce4ec
```

## Performance Architecture

### Message Processing Pipeline

```mermaid
graph TB
    subgraph "Ingress"
        IN[Incoming Messages]
        BATCH[Batching Layer]
        PRIO[Priority Queue]
    end
    
    subgraph "Processing"
        FAST[Fast Path - Direct Dispatch]
        SLOW[Slow Path - Queued]
        BULK[Bulk Processing]
    end
    
    subgraph "Optimization"
        CACHE[Result Cache]
        DEDUPE[Deduplication]
        COMPRESS[Compression]
    end
    
    subgraph "Egress"
        OUT[Processed Results]
        METRICS[Performance Metrics]
    end
    
    IN --> BATCH
    BATCH --> PRIO
    
    PRIO -->|<1ms| FAST
    PRIO -->|>1ms| SLOW
    PRIO -->|batch| BULK
    
    FAST --> CACHE
    SLOW --> DEDUPE
    BULK --> COMPRESS
    
    CACHE --> OUT
    DEDUPE --> OUT
    COMPRESS --> OUT
    
    OUT --> METRICS
    
    style FAST fill:#c8e6c9
    style CACHE fill:#ffecb3
```

### Performance Monitoring

```mermaid
graph LR
    subgraph "Metrics Collection"
        M1[Throughput]
        M2[Latency P50/P95/P99]
        M3[Memory Usage]
        M4[Actor Utilization]
    end
    
    subgraph "Analysis"
        A1[Bottleneck Detection]
        A2[Trend Analysis]
        A3[Anomaly Detection]
    end
    
    subgraph "Optimization"
        O1[Auto-Scaling]
        O2[Load Balancing]
        O3[Circuit Breaking]
    end
    
    M1 --> A1
    M2 --> A1
    M3 --> A2
    M4 --> A3
    
    A1 --> O1
    A2 --> O2
    A3 --> O3
    
    style M2 fill:#ffcdd2
    style A1 fill:#f8bbd0
    style O1 fill:#e1bee7
```

## Deployment Architecture

### Single Application Deployment

```mermaid
graph TB
    subgraph "iOS/macOS App"
        APP[Application]
        MB[Message Bus]
        STORE[Local Event Store]
    end
    
    subgraph "Features"
        F1[Feature Module 1]
        F2[Feature Module 2]
        F3[Feature Module 3]
    end
    
    APP --> MB
    MB --> STORE
    
    F1 -.->|@Subscribe| MB
    F2 -.->|@Subscribe| MB
    F3 -.->|@Subscribe| MB
    
    style APP fill:#e3f2fd
    style MB fill:#fff3e0
```

### Distributed System Deployment

```mermaid
graph TB
    subgraph "Client Apps"
        IOS[iOS App]
        MAC[macOS App]
        WATCH[watchOS App]
    end
    
    subgraph "Backend Services"
        API[API Gateway]
        MB1[Message Bus Instance 1]
        MB2[Message Bus Instance 2]
        MB3[Message Bus Instance 3]
    end
    
    subgraph "Infrastructure"
        LB[Load Balancer]
        ES[Event Store Cluster]
        CACHE[Redis Cache]
    end
    
    IOS --> API
    MAC --> API
    WATCH --> API
    
    API --> LB
    LB --> MB1
    LB --> MB2
    LB --> MB3
    
    MB1 --> ES
    MB2 --> ES
    MB3 --> ES
    
    MB1 --> CACHE
    MB2 --> CACHE
    MB3 --> CACHE
    
    style IOS fill:#e8f5e9
    style MAC fill:#e3f2fd
    style WATCH fill:#fff3e0
    style ES fill:#ffebee
```

### Microservices Architecture

```mermaid
graph TB
    subgraph "Service Mesh"
        SVC1[Order Service]
        SVC2[Payment Service]
        SVC3[Inventory Service]
        SVC4[Shipping Service]
    end
    
    subgraph "Message Bus Infrastructure"
        BROKER[Event Broker]
        SAGA[Saga Coordinator]
        PROJ[Projection Service]
    end
    
    subgraph "Cross-Cutting Concerns"
        AUTH[Authentication]
        LOG[Logging]
        TRACE[Tracing]
        METRIC[Metrics]
    end
    
    SVC1 -->|Events| BROKER
    SVC2 -->|Events| BROKER
    SVC3 -->|Events| BROKER
    SVC4 -->|Events| BROKER
    
    BROKER --> SAGA
    BROKER --> PROJ
    
    SAGA -->|Commands| SVC1
    SAGA -->|Commands| SVC2
    SAGA -->|Commands| SVC3
    SAGA -->|Commands| SVC4
    
    SVC1 --> AUTH
    SVC1 --> LOG
    SVC1 --> TRACE
    SVC1 --> METRIC
    
    style BROKER fill:#fff9c4
    style SAGA fill:#f3e5f5
```

## Advanced Macro Architectures

### @StateProjection Architecture

```mermaid
stateDiagram-v2
    [*] --> Initial
    
    Initial --> StateChange: Property Modified
    StateChange --> EventGeneration: Create Change Event
    EventGeneration --> EventPublish: Publish to Bus
    EventPublish --> Projection: Update Projections
    
    Projection --> Observer1: Notify Observer
    Projection --> Observer2: Notify Observer
    Projection --> ObserverN: Notify Observer
    
    Observer1 --> UIUpdate: Update View
    Observer2 --> Cache: Update Cache
    ObserverN --> Analytics: Track Change
    
    UIUpdate --> [*]
    Cache --> [*]
    Analytics --> [*]
    
    note right of EventGeneration
        Automatic event creation
        from @Published properties
    end note
    
    note right of Projection
        All observers receive
        consistent state updates
    end note
```

### @CircuitBreaker State Machine

```mermaid
stateDiagram-v2
    [*] --> Closed
    
    Closed --> Open: Failure Threshold Reached
    Closed --> Closed: Success
    Closed --> Closed: Failure < Threshold
    
    Open --> HalfOpen: Timeout Expired
    Open --> Open: Request → Fallback
    
    HalfOpen --> Closed: Success
    HalfOpen --> Open: Failure
    HalfOpen --> HalfOpen: Testing
    
    note right of Open
        All requests immediately
        return fallback response
    end note
    
    note right of HalfOpen
        Limited requests allowed
        to test if service recovered
    end note
```

## Performance Benchmarks Architecture

```mermaid
graph TD
    subgraph "Benchmark Suite"
        B1[Throughput Test]
        B2[Latency Test]
        B3[Memory Test]
        B4[Concurrency Test]
    end
    
    subgraph "Test Scenarios"
        S1[1K msg/sec]
        S2[10K msg/sec]
        S3[100K msg/sec]
        S4[1M msg/sec]
    end
    
    subgraph "Metrics"
        M1[Messages/Second]
        M2[P50/P95/P99 Latency]
        M3[Memory Usage]
        M4[CPU Usage]
    end
    
    subgraph "Comparison"
        C1[vs NotificationCenter]
        C2[vs Combine]
        C3[vs RxSwift]
        C4[vs Custom Bus]
    end
    
    B1 --> S1
    B1 --> S2
    B1 --> S3
    B1 --> S4
    
    S1 --> M1
    S2 --> M2
    S3 --> M3
    S4 --> M4
    
    M1 --> C1
    M2 --> C2
    M3 --> C3
    M4 --> C4
    
    style B1 fill:#c8e6c9
    style M2 fill:#ffecb3
    style C1 fill:#e1bee7
```

## Summary

These architectural diagrams illustrate the comprehensive design of the Swift Message Bus:

1. **Layered Architecture**: Clear separation between macros, API, runtime, and platform integration
2. **Actor-Based Concurrency**: Thread-safe by design with Swift actors
3. **CQRS/Event Sourcing**: Native support for modern architectural patterns
4. **Performance Pipeline**: Optimized for sub-millisecond latency
5. **Macro Compilation**: Compile-time code generation for zero-overhead abstractions
6. **Deployment Flexibility**: From single app to distributed microservices

The architecture prioritizes:
- **Type Safety**: Compile-time validation at every level
- **Performance**: Direct dispatch paths, minimal overhead
- **Scalability**: From simple apps to enterprise systems
- **Developer Experience**: Intuitive APIs powered by macros