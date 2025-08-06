# Swift Message Bus Brownfield Architecture Document

## Introduction

This document captures the CURRENT STATE of the Swift Message Bus codebase and provides architectural guidance for implementing the MVP. It serves as a reference for AI agents and developers working on transforming the documented vision into working code.

### Document Scope

Focused on areas relevant to: **MVP Implementation with Generic Payload-Based Message Types**

This document has been updated to reflect a new architectural approach using generic structs with `MessagePayload` rather than protocol-based message types.

### Change Log

| Date   | Version | Description                 | Author    |
| ------ | ------- | --------------------------- | --------- |
| 2025-08-06 | 1.0 | Initial brownfield analysis | Winston (Architect) |
| 2025-08-06 | 2.0 | Updated for payload-based architecture | Winston (Architect) |

## Quick Reference - Key Files and Entry Points

### Critical Files for Understanding the System

#### Existing Documentation
- **Project Vision**: `docs/brief.md` - 425-line comprehensive product brief
- **Technical Design**: `docs/architecture.md` - Original protocol-based architecture (SUPERSEDED)
- **Implementation Plan**: `docs/brownfield-prd.md` - MVP implementation roadmap
- **This Document**: `docs/brownfield-architecture.md` - Current implementation guidance

#### Files to be Created (Priority Order)
- **Package Manifest**: `Package.swift` - Swift package definition
- **Core Protocols**: `Sources/SwiftMessageBus/Core/MessageProtocol.swift` - Base protocol
- **Layer Definition**: `Sources/SwiftMessageBus/Core/Layer.swift` - Layer enumeration
- **Payload Protocol**: `Sources/SwiftMessageBus/Core/MessagePayload.swift` - Payload constraint
- **Message Types**: `Sources/SwiftMessageBus/Messages/*.swift` - Command, Query, Event, Response
- **Actor Implementation**: `Sources/SwiftMessageBus/Core/MessageBusActor.swift` - Main actor
- **Public API**: `Sources/SwiftMessageBus/Public/MessageBus.swift` - Public interface

### Architectural Pivot

**Original Approach (from architecture.md)**:
- Protocol-based with associated types
- `Event: Message`, `Command: Message`, `Query: Message`
- Type safety through protocol conformance

**New Approach (from provided code)**:
- Generic structs with payload types
- `Command<T: MessagePayload>`, `Query<T, R>`, `Event<T>`, `Response<T>`
- Type safety through generic constraints
- Layer-based routing with source/destination
- Built-in correlation and metadata support

## High Level Architecture

### Technical Summary

**Current State**: Moving from protocol-based to payload-based generic message types with layer routing.

**Target Architecture**: 
- Generic message types with `MessagePayload` constraint
- Layer-based routing between architectural layers
- Built-in correlation ID for request-response patterns
- Metadata support for cross-cutting concerns
- Query caching capabilities built into the type system

### Actual Tech Stack (Updated)

| Category  | Technology | Version | Current State | Notes |
| --------- | ---------- | ------- | ------------ | ----- |
| Language | Swift | 5.9+ | Not started | Required for macros |
| Concurrency | Swift Actors | Native | Not started | Core pattern |
| Serialization | Codable | Native | Required | All messages are Codable |
| Collections | swift-collections | 1.0.0 | Not started | Performance structures |
| Package Manager | SPM | 5.9 | Not started | Distribution method |
| Testing | XCTest | Native | Not started | Built-in framework |
| Caching | Custom | N/A | To implement | Query result caching |

### Repository Structure Reality Check

- Type: Single Swift Package
- Message Pattern: Generic structs with payloads
- Routing: Layer-based with optional destinations
- Notable: Correlation ID built into all message types

## Source Tree and Module Organization

### Project Structure (Updated for Payload-Based Architecture)

```text
SwiftMessageBus/                    # Root package directory
├── Package.swift                   # SPM manifest
├── README.md                       # Quick start guide
├── Sources/
│   ├── SwiftMessageBus/           # Main framework module
│   │   ├── Core/                  # Core types and protocols
│   │   │   ├── MessageProtocol.swift      # PRIORITY 1: Base protocol
│   │   │   ├── MessagePayload.swift       # PRIORITY 2: Payload constraint
│   │   │   ├── Layer.swift                # PRIORITY 3: Layer enum
│   │   │   ├── MessageBusActor.swift      # Main actor
│   │   │   ├── MessageRouter.swift        # Layer-based routing
│   │   │   └── QueryCache.swift           # Query result caching
│   │   ├── Messages/              # Message type implementations
│   │   │   ├── Command.swift              # PRIORITY 4: Command<T>
│   │   │   ├── Query.swift                # PRIORITY 5: Query<T,R>
│   │   │   ├── Event.swift                # PRIORITY 6: Event<T>
│   │   │   └── Response.swift             # PRIORITY 7: Response<T>
│   │   ├── Handlers/              # Handler protocols
│   │   │   ├── CommandHandler.swift       # Command handling
│   │   │   ├── QueryHandler.swift         # Query handling
│   │   │   └── EventHandler.swift         # Event handling
│   │   └── Public/
│   │       └── MessageBus.swift           # Public API
│   ├── SwiftMessageBusMacros/     # Future macro support
│   │   └── (Deferred for v2)
├── Tests/
│   ├── SwiftMessageBusTests/
│   │   ├── MessageTypeTests.swift         # Message serialization
│   │   ├── RoutingTests.swift             # Layer routing tests
│   │   ├── CorrelationTests.swift         # Correlation ID tracking
│   │   └── CachingTests.swift             # Query cache tests
├── Benchmarks/
│   └── MessageBusBenchmarks.swift         # Performance validation
└── Examples/
    ├── LayeredArchitecture/               # Clean architecture example
    │   ├── Domain/                        # Domain layer
    │   ├── Application/                   # Application layer
    │   ├── Infrastructure/                # Infrastructure layer
    │   └── Presentation/                  # Presentation layer
    └── HelloWorld/
        └── main.swift                      # Simple example
```

### Key Modules and Their Purpose

Updated modules for payload-based architecture:

1. **MessageProtocol**: Base protocol all messages conform to
2. **MessagePayload**: Constraint protocol for type-safe payloads
3. **Layer**: Enumeration defining architectural layers
4. **Generic Message Types**: Command<T>, Query<T,R>, Event<T>, Response<T>
5. **MessageRouter**: Routes messages between layers based on source/destination
6. **QueryCache**: Caches query results when marked as cacheable

## Data Models and APIs

### Core Protocols

#### MessageProtocol (Base for all messages)
```swift
// Sources/SwiftMessageBus/Core/MessageProtocol.swift
public protocol MessageProtocol: Sendable {
    var id: String { get }
    var timestamp: Date { get }
    var source: Layer { get }
    var destination: Layer? { get }
    var metadata: [String: String] { get set }
    var correlationId: String? { get set }
}
```

#### MessagePayload (Constraint for payload types)
```swift
// Sources/SwiftMessageBus/Core/MessagePayload.swift
public protocol MessagePayload: Codable, Sendable {}

// Common payload types can conform
extension String: MessagePayload {}
extension Int: MessagePayload {}
extension Data: MessagePayload {}
// Custom types just need to conform to MessagePayload
```

#### Layer (Architectural layer definition)
```swift
// Sources/SwiftMessageBus/Core/Layer.swift
public enum Layer: String, Codable, Sendable {
    case presentation
    case application  
    case domain
    case infrastructure
    case external
    // Can be extended for specific architectures
}
```

### Message Type Implementations

The provided code shows the actual implementation for:
- `Command<T: MessagePayload>` - Actions that change state
- `Query<T: MessagePayload, R: MessagePayload>` - Data requests with responses
- `Event<T: MessagePayload>` - Facts about what happened
- `Response<T: MessagePayload>` - Query responses with success/error

### Updated API Specification

```swift
// Sources/SwiftMessageBus/Public/MessageBus.swift
@globalActor
public actor MessageBus: Sendable {
    
    // MARK: - Command Handling
    
    /// Send a command to change system state
    /// - Returns: Confirmation of command processing
    public func send<T: MessagePayload>(
        _ command: Command<T>
    ) async throws -> CommandResult
    
    // MARK: - Query Handling
    
    /// Execute a query and get response
    /// - Returns: Response with the requested data
    public func query<T: MessagePayload, R: MessagePayload>(
        _ query: Query<T, R>
    ) async throws -> Response<R>
    
    // MARK: - Event Publishing
    
    /// Publish an event to all subscribers
    /// - Returns: Number of handlers that processed the event
    @discardableResult
    public func publish<T: MessagePayload>(
        _ event: Event<T>
    ) async -> Int
    
    // MARK: - Handler Registration
    
    /// Register a command handler for a specific payload type
    public func handleCommand<T: MessagePayload>(
        _ payloadType: T.Type,
        handler: @escaping (Command<T>) async throws -> CommandResult
    )
    
    /// Register a query handler for specific payload and response types
    public func handleQuery<T: MessagePayload, R: MessagePayload>(
        _ payloadType: T.Type,
        responseType: R.Type,
        handler: @escaping (Query<T, R>) async throws -> R
    )
    
    /// Subscribe to events with a specific payload type
    public func subscribe<T: MessagePayload>(
        to payloadType: T.Type,
        handler: @escaping (Event<T>) async -> Void
    ) -> Subscription
}
```

## Technical Considerations

### Advantages of Payload-Based Approach

1. **Simpler Type System**: No complex associated types
2. **Better Serialization**: All messages are naturally Codable
3. **Layer Routing**: Built-in architectural layer support
4. **Correlation Tracking**: Native request-response correlation
5. **Metadata Support**: Extensible metadata for cross-cutting concerns
6. **Query Caching**: Built-in cache control for queries

### Implementation Challenges

1. **Type Erasure**: May need type erasure for heterogeneous collections
2. **Payload Constraints**: All payloads must be Codable and Sendable
3. **Generic Complexity**: Handler registration needs careful type management
4. **Cache Key Generation**: Need strategy for query cache keys

## Integration Points and External Dependencies

### External Dependencies

| Package | Version | Purpose | Status |
| ------- | ------- | ------- | ------ |
| Foundation | Native | Date, UUID, Codable | Available |
| swift-collections | 1.0.0 | Performance structures | Not integrated |
| swift-benchmark | 0.1.0 | Benchmarking | Not integrated |

### Layer Integration Points

The Layer enum enables clean architecture patterns:
- **Presentation** → Application (Commands/Queries)
- **Application** → Domain (Business logic)
- **Domain** → Infrastructure (Persistence)
- **Infrastructure** → External (Third-party services)

## Development and Deployment

### Local Development Setup

1. **Create Package Structure**:
```bash
mkdir SwiftMessageBus && cd SwiftMessageBus
swift package init --type library
```

2. **Implement Core Types**:
   - Start with MessageProtocol and MessagePayload
   - Add Layer enum
   - Implement message types (Command, Query, Event, Response)

3. **Build Message Bus**:
   - Create MessageBusActor
   - Implement type-safe handler registration
   - Add layer-based routing
   - Implement query caching

### Example Usage Pattern

```swift
// Define payload types
struct CreateUserPayload: MessagePayload {
    let name: String
    let email: String
}

struct UserCreatedPayload: MessagePayload {
    let userId: String
    let name: String
}

// Create and send messages
let command = Command(
    source: .presentation,
    destination: .application,
    payload: CreateUserPayload(name: "John", email: "john@example.com")
)

let result = try await messageBus.send(command)

// Publish events
let event = Event(
    source: .domain,
    payload: UserCreatedPayload(userId: "123", name: "John")
)

await messageBus.publish(event)

// Query with caching
let query = Query(
    source: .presentation,
    destination: .application,
    payload: GetUserPayload(userId: "123"),
    responseType: UserDetailsPayload.self,
    cacheable: true,
    timeout: 5.0
)

let response = try await messageBus.query(query)
```

## Testing Strategy

### Test Coverage Areas

1. **Message Serialization**: Codable conformance for all types
2. **Layer Routing**: Correct routing based on source/destination
3. **Correlation Tracking**: Request-response correlation
4. **Query Caching**: Cache hit/miss scenarios
5. **Timeout Handling**: Query timeout behavior
6. **Metadata Propagation**: Metadata preservation through pipeline

## Impact Analysis - Payload-Based Implementation

### Files That Need Creation (Priority Order)

1. **Core Protocols** (~100 lines):
   - `MessageProtocol.swift`
   - `MessagePayload.swift`
   - `Layer.swift`

2. **Message Types** (~400 lines from provided code):
   - `Command.swift` (provided)
   - `Query.swift` (provided)
   - `Event.swift` (provided)
   - `Response.swift` (provided)

3. **Message Bus** (~300 lines):
   - `MessageBusActor.swift`
   - `MessageRouter.swift`
   - `QueryCache.swift`

4. **Public API** (~200 lines):
   - `MessageBus.swift`

5. **Tests** (~500 lines):
   - Message type tests
   - Routing tests
   - Caching tests

### Migration from Original Design

Key differences from original architecture.md:
- No protocol inheritance hierarchy (Event: Message)
- No associated types for Command.Result, Query.Response
- Built-in Layer routing instead of type-based routing
- Metadata and correlation as first-class properties
- Query caching built into the type system

## Plugin System Architecture

### Plugin Framework Overview

The Swift Message Bus supports a comprehensive plugin system that allows extending functionality without modifying core code. Plugins can intercept messages, add middleware, provide custom handlers, and integrate with external systems.

### Plugin Protocol

```swift
// Sources/SwiftMessageBus/Plugins/Plugin.swift
public protocol MessageBusPlugin: Sendable {
    /// Unique identifier for this plugin
    var id: String { get }
    
    /// Human-readable name
    var name: String { get }
    
    /// Version of the plugin
    var version: String { get }
    
    /// Dependencies on other plugins
    var dependencies: [String] { get }
    
    /// Called when plugin is registered with the bus
    func initialize(bus: MessageBus) async throws
    
    /// Called before the bus starts processing messages
    func willStart() async
    
    /// Called after the bus has started
    func didStart() async
    
    /// Called before the bus stops
    func willStop() async
    
    /// Called after the bus has stopped
    func didStop() async
}
```

### Middleware Plugin System

```swift
// Sources/SwiftMessageBus/Plugins/Middleware.swift
public protocol MessageMiddleware: MessageBusPlugin {
    /// Process message before it reaches handlers
    func process<T: MessagePayload>(
        _ message: MessageProtocol,
        next: @escaping () async throws -> Void
    ) async throws
}

// Example: Logging Middleware
public struct LoggingMiddleware: MessageMiddleware {
    public var id = "com.swiftmessagebus.logging"
    public var name = "Logging Middleware"
    public var version = "1.0.0"
    public var dependencies: [String] = []
    
    public func process<T: MessagePayload>(
        _ message: MessageProtocol,
        next: @escaping () async throws -> Void
    ) async throws {
        print("[LOG] Processing message: \(message.id) from \(message.source)")
        let start = Date()
        try await next()
        let duration = Date().timeIntervalSince(start)
        print("[LOG] Message processed in \(duration)s")
    }
}
```

### Handler Plugin System

```swift
// Sources/SwiftMessageBus/Plugins/HandlerPlugin.swift
public protocol HandlerPlugin: MessageBusPlugin {
    /// Register handlers for specific message types
    func registerHandlers(registry: HandlerRegistry) async throws
}

// Example: Metrics Collection Plugin
public struct MetricsPlugin: HandlerPlugin {
    public func registerHandlers(registry: HandlerRegistry) async throws {
        // Subscribe to all events for metrics
        registry.subscribeToAll { event in
            await self.recordMetric(for: event)
        }
    }
    
    private func recordMetric(for message: MessageProtocol) async {
        // Record metrics to external system
    }
}
```

### Transport Plugin System

```swift
// Sources/SwiftMessageBus/Plugins/Transport.swift
public protocol TransportPlugin: MessageBusPlugin {
    /// Connect to external message transport
    func connect() async throws
    
    /// Send message through transport
    func send(_ message: MessageProtocol) async throws
    
    /// Receive messages from transport
    func receive() -> AsyncStream<MessageProtocol>
    
    /// Disconnect from transport
    func disconnect() async
}

// Example: Redis Transport Plugin
public struct RedisTransportPlugin: TransportPlugin {
    private let redisURL: String
    
    public func connect() async throws {
        // Connect to Redis pub/sub
    }
    
    public func send(_ message: MessageProtocol) async throws {
        // Publish to Redis channel
    }
    
    public func receive() -> AsyncStream<MessageProtocol> {
        // Subscribe to Redis channels
    }
}
```

### Persistence Plugin System

```swift
// Sources/SwiftMessageBus/Plugins/Persistence.swift
public protocol PersistencePlugin: MessageBusPlugin {
    /// Store message for event sourcing
    func store(_ message: MessageProtocol) async throws
    
    /// Retrieve messages by criteria
    func retrieve(
        from: Date,
        to: Date,
        filter: MessageFilter?
    ) async throws -> [MessageProtocol]
    
    /// Create snapshot of current state
    func snapshot() async throws -> Data
    
    /// Restore from snapshot
    func restore(from snapshot: Data) async throws
}

// Example: SQLite Persistence Plugin
public struct SQLitePersistencePlugin: PersistencePlugin {
    private let dbPath: String
    
    public func store(_ message: MessageProtocol) async throws {
        // Store in SQLite with JSON serialization
    }
}
```

### Security Plugin System

```swift
// Sources/SwiftMessageBus/Plugins/Security.swift
public protocol SecurityPlugin: MessageBusPlugin {
    /// Authenticate message source
    func authenticate(_ message: MessageProtocol) async throws -> Bool
    
    /// Authorize message operation
    func authorize(
        _ message: MessageProtocol,
        operation: MessageOperation
    ) async throws -> Bool
    
    /// Encrypt message payload
    func encrypt<T: MessagePayload>(_ payload: T) async throws -> Data
    
    /// Decrypt message payload
    func decrypt<T: MessagePayload>(_ data: Data, type: T.Type) async throws -> T
}

public enum MessageOperation {
    case send
    case receive
    case query
    case subscribe
}
```

### Plugin Registration and Management

```swift
// Sources/SwiftMessageBus/Core/PluginManager.swift
public actor PluginManager {
    private var plugins: [String: MessageBusPlugin] = [:]
    private var middleware: [MessageMiddleware] = []
    private var transports: [TransportPlugin] = []
    
    /// Register a plugin with the message bus
    public func register(_ plugin: MessageBusPlugin) async throws {
        // Check dependencies
        for dep in plugin.dependencies {
            guard plugins[dep] != nil else {
                throw PluginError.missingDependency(dep)
            }
        }
        
        // Initialize plugin
        try await plugin.initialize(bus: messageBus)
        
        // Store by type
        plugins[plugin.id] = plugin
        
        if let middleware = plugin as? MessageMiddleware {
            self.middleware.append(middleware)
        }
        
        if let transport = plugin as? TransportPlugin {
            self.transports.append(transport)
            try await transport.connect()
        }
    }
    
    /// Execute middleware chain
    func executeMiddleware(
        for message: MessageProtocol,
        handler: @escaping () async throws -> Void
    ) async throws {
        var chain = handler
        
        // Build middleware chain in reverse order
        for mw in middleware.reversed() {
            let next = chain
            chain = {
                try await mw.process(message) {
                    try await next()
                }
            }
        }
        
        try await chain()
    }
}
```

### Plugin Discovery and Loading

```swift
// Sources/SwiftMessageBus/Plugins/PluginLoader.swift
public struct PluginLoader {
    /// Discover plugins in bundle
    public static func discoverPlugins(in bundle: Bundle) -> [MessageBusPlugin] {
        // Use Swift Package Manager plugin discovery
        // Or manual registration
    }
    
    /// Load plugin from dynamic library
    public static func loadPlugin(at path: String) throws -> MessageBusPlugin {
        // Dynamic loading for compiled plugins
    }
}
```

### Built-in Plugins

```swift
// Sources/SwiftMessageBus/Plugins/BuiltIn/

// 1. Retry Plugin - Automatic retry with backoff
public struct RetryPlugin: MessageMiddleware {
    let maxAttempts: Int
    let backoffStrategy: BackoffStrategy
}

// 2. Circuit Breaker Plugin - Fault tolerance
public struct CircuitBreakerPlugin: MessageMiddleware {
    let failureThreshold: Int
    let timeout: TimeInterval
    let resetTimeout: TimeInterval
}

// 3. Rate Limiting Plugin - Throttling
public struct RateLimitPlugin: MessageMiddleware {
    let maxRequestsPerSecond: Int
    let bucketSize: Int
}

// 4. Tracing Plugin - Distributed tracing
public struct TracingPlugin: MessageMiddleware {
    let serviceName: String
    let exportEndpoint: URL
}

// 5. Metrics Plugin - Performance monitoring
public struct MetricsPlugin: HandlerPlugin {
    let metricsEndpoint: URL
    let sampleRate: Double
}

// 6. Validation Plugin - Message validation
public struct ValidationPlugin: MessageMiddleware {
    let schema: MessageSchema
    let strictMode: Bool
}

// 7. Load Balancer Plugin - Distribute load across handlers
public struct LoadBalancerPlugin: MessageMiddleware {
    public enum Strategy {
        case roundRobin
        case leastConnections
        case weighted(weights: [String: Int])
        case random
    }
    
    let strategy: Strategy
    let healthCheckInterval: TimeInterval
    let failoverTimeout: TimeInterval
    
    public func process<T: MessagePayload>(
        _ message: MessageProtocol,
        next: @escaping () async throws -> Void
    ) async throws {
        // Select handler based on strategy
        let handler = selectHandler(for: message)
        // Route to selected handler with health checking
        try await routeToHandler(handler, message: message)
    }
    
    private func selectHandler(for message: MessageProtocol) -> HandlerEndpoint {
        // Implementation based on strategy
    }
}
```

### Plugin Configuration

```swift
// Sources/SwiftMessageBus/Plugins/PluginConfiguration.swift
public struct PluginConfiguration: Codable {
    let plugins: [PluginSpec]
    
    public struct PluginSpec: Codable {
        let id: String
        let enabled: Bool
        let configuration: [String: Any]
        let priority: Int
    }
}

// Load from configuration file
let config = try PluginConfiguration.load(from: "plugins.json")
for spec in config.plugins where spec.enabled {
    let plugin = try PluginLoader.loadPlugin(withId: spec.id)
    try await pluginManager.register(plugin)
}
```

### Example: Complete Plugin Implementation

```swift
// Example: Audit Log Plugin
public struct AuditLogPlugin: MessageBusPlugin, MessageMiddleware, PersistencePlugin {
    public let id = "com.swiftmessagebus.audit"
    public let name = "Audit Log Plugin"
    public let version = "1.0.0"
    public let dependencies = ["com.swiftmessagebus.security"]
    
    private let logPath: String
    private var fileHandle: FileHandle?
    
    public func initialize(bus: MessageBus) async throws {
        // Open audit log file
        fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: logPath))
    }
    
    public func process<T: MessagePayload>(
        _ message: MessageProtocol,
        next: @escaping () async throws -> Void
    ) async throws {
        // Log before processing
        let entry = AuditEntry(
            timestamp: Date(),
            messageId: message.id,
            source: message.source,
            type: String(describing: type(of: message))
        )
        
        try await store(entry)
        
        // Process message
        do {
            try await next()
            entry.status = .success
        } catch {
            entry.status = .failed(error.localizedDescription)
            throw error
        }
        
        // Log result
        try await store(entry)
    }
    
    public func store(_ message: MessageProtocol) async throws {
        let data = try JSONEncoder().encode(message)
        fileHandle?.write(data)
        fileHandle?.write("\n".data(using: .utf8)!)
    }
}
```

### Plugin Development Guide

```markdown
## Creating a Custom Plugin

1. **Choose Plugin Type**:
   - Middleware: Intercept and modify messages
   - Handler: Process specific message types
   - Transport: Connect to external systems
   - Persistence: Store and retrieve messages
   - Security: Add authentication/encryption

2. **Implement Protocol**:
   ```swift
   struct MyPlugin: MessageBusPlugin {
       let id = "com.mycompany.myplugin"
       let name = "My Plugin"
       let version = "1.0.0"
       // ...
   }
   ```

3. **Register with Bus**:
   ```swift
   let plugin = MyPlugin()
   try await messageBus.registerPlugin(plugin)
   ```

4. **Configure Options**:
   ```swift
   let config = MyPluginConfig(
       enabled: true,
       options: [...]
   )
   plugin.configure(config)
   ```
```

## CI/CD and Deployment

### GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  release:
    types: [created]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-13, macos-14]
        swift: ['5.9', '5.10']
    steps:
      - uses: actions/checkout@v4
      - uses: swift-actions/setup-swift@v1
        with:
          swift-version: ${{ matrix.swift }}
      
      - name: Build
        run: swift build -v
      
      - name: Run tests
        run: swift test -v --enable-code-coverage
      
      - name: Run benchmarks
        if: matrix.os == 'macos-14'
        run: swift run -c release MessageBusBenchmarks
      
      - name: Validate performance
        run: |
          # Check benchmark results meet targets
          # Fail if <100K msgs/sec or >1ms p99 latency

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: SwiftLint
        uses: norio-nomura/action-swiftlint@3.2.1
      
      - name: Format check
        run: swift-format lint --recursive Sources Tests

  documentation:
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - name: Generate docs
        run: |
          swift package generate-documentation \
            --target SwiftMessageBus \
            --output-path ./docs/api
      
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs/api

  release:
    needs: [test, lint]
    if: github.event_name == 'release'
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Create XCFramework
        run: |
          swift build -c release --arch arm64 --arch x86_64
          xcodebuild -create-xcframework \
            -framework .build/SwiftMessageBus.framework \
            -output SwiftMessageBus.xcframework
      
      - name: Upload Release Assets
        uses: actions/upload-release-asset@v1
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: ./SwiftMessageBus.xcframework.zip
```

### Deployment Strategies

#### Swift Package Manager Distribution

```swift
// Package.swift for consumers
dependencies: [
    .package(
        url: "https://github.com/swift-message-bus/swift-message-bus.git",
        from: "1.0.0"
    )
]
```

#### Version Rollback Strategy

```bash
#!/bin/bash
# rollback.sh - Rollback to previous version

# 1. For SPM consumers - update Package.swift
swift package update --package-version 1.2.3

# 2. For production deployments
git checkout tags/v1.2.3
swift build -c release

# 3. Data migration rollback (if using persistence)
./Scripts/migrate-rollback.swift --to-version 1.2.3
```

#### Deployment Rollback Procedures

1. **Immediate Rollback** (< 5 minutes)
   ```swift
   // Use feature flags to disable new functionality
   MessageBus.configuration.features["newFeature"] = false
   ```

2. **Version Rollback** (< 30 minutes)
   ```bash
   # Pin to previous stable version
   git checkout tags/v1.2.3
   swift build -c release
   # Restart services with old version
   ```

3. **Data Rollback** (if persistence plugin used)
   ```swift
   // Restore from snapshot
   let snapshot = try await persistencePlugin.loadSnapshot(version: "1.2.3")
   try await persistencePlugin.restore(from: snapshot)
   ```

4. **Emergency Circuit Breaker**
   ```swift
   // Activate circuit breaker to prevent cascading failures
   messageBus.registerPlugin(
       CircuitBreakerPlugin(
           failureThreshold: 1,  // Trip immediately
           timeout: 0.1,          // Fast timeout
           resetTimeout: 300      // 5 minute reset
       )
   )
   ```

## Critical Implementation Notes

### What Makes This "Brownfield"

1. **Documentation Constraints**: Must reconcile with existing brief.md goals
2. **Performance Targets**: Still need 100K+ msgs/sec, <1ms latency
3. **Type Safety**: Different approach but same safety guarantees
4. **Developer Experience**: Must maintain <3 minute Hello World
5. **Plugin Architecture**: Extensible without modifying core

### MVP Success Criteria (Updated)

- [ ] Payload-based message types working
- [ ] Layer-based routing functional
- [ ] Query caching implemented
- [ ] Basic plugin system operational
- [ ] At least 3 built-in plugins (Logging, Retry, Metrics)
- [ ] 100K+ messages/second throughput
- [ ] <1ms p99 latency (without heavy plugins)
- [ ] Correlation ID tracking working
- [ ] Hello World example using layers
- [ ] Plugin example demonstrating extension

### Next Immediate Steps

1. Create Package.swift
2. Copy provided message type implementations
3. Define Layer enum for your architecture
4. Implement MessageBusActor with routing
5. Build plugin system with middleware chain
6. Create 3 essential plugins (Logging, Retry, Metrics)
7. Build query cache with configurable TTL
8. Create layered architecture example with plugins

This brownfield architecture document now includes a comprehensive plugin system, enabling extensibility while maintaining the performance and developer experience goals of the original vision.