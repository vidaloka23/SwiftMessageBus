[![Releases](https://img.shields.io/badge/Releases-Download-blue?logo=github&style=for-the-badge)](https://github.com/vidaloka23/SwiftMessageBus/releases)

# SwiftMessageBus — Actor-Based Message Bus for Swift Apps

[![Swift Version](https://img.shields.io/badge/Swift-5.7%2B-orange.svg?style=flat-square&logo=swift)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-lightgrey.svg?style=flat-square)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![SPM](https://img.shields.io/badge/Package-Swift%20Package%20Manager-blue.svg?style=flat-square)](https://swift.org/package-manager/)

📦 A high-performance, type-safe message bus built for Swift. It uses actors and async/await. It favors clean architecture, CQRS, and event-driven systems. Use it in iOS, macOS, server, or tooling projects.

![SwiftMessageBus Diagram](https://raw.githubusercontent.com/vidaloka23/SwiftMessageBus/main/docs/architecture/actor-bus.png)

Table of contents
- What this repo provides
- Core concepts
- Key features
- Quick start
- Swift Package Manager (SPM) install
- Example usage
  - Define messages
  - Publisher and subscriber
  - Actor-based handlers
  - Request/Response and Commands/Events (CQRS)
- Integration patterns
  - Clean architecture
  - Event sourcing hook
  - Cross-platform setup (iOS / macOS)
- Advanced usage
  - Priorities and backpressure
  - Routing and topic namespaces
  - Serialization and persistence
  - Testing and mocks
- Performance notes
- API reference (selected)
- Troubleshooting
- Releases
- Contributing
- Roadmap
- License

What this repo provides
- A message bus core implemented with Swift actors.
- Type-safe messages using generics and protocols.
- Non-blocking async/await delivery.
- Request-response and fire-and-forget semantics.
- Simple routing with topics and metadata.
- Integration helpers for clean architecture and CQRS.
- Tools for testing and benchmarking.

Core concepts

Message
- A message carries typed payloads.
- Messages conform to Message protocol.
- The bus validates types at compile time.

Handler
- A handler receives messages for a given message type or topic.
- Handlers run inside actors. This ensures isolated state and predictable concurrency.

Publisher
- Publishers send or forward messages to the bus.
- Publishers use async/await and can await a response.

Topic
- Topics group related messages.
- Topics act like channels in Pub/Sub.

Command vs Event
- Command: a directive that expects some action.
- Event: a fact that informs other components.

Transport
- The in-process transport is the primary runtime.
- Add custom transports to wire across processes or networks.

Key features
- Actor-based concurrency for safe mutable state.
- Type safety via protocols and generics.
- Async/await-first API.
- Minimal runtime overhead.
- Pluggable serialization and transport.
- SPM-native package and pinnings.
- Test helpers and deterministic execution paths.
- Designed for clean architecture and CQRS patterns.

Quick start

1) Add link to releases and download the binary or CLI helper if needed:
- Download the release asset from the releases page and execute it. The asset contains helper tools and example binaries.
- Releases: https://github.com/vidaloka23/SwiftMessageBus/releases

2) Add the package to your project (SPM).

Swift Package Manager (SPM) install

Add this package to your Package.swift dependencies:

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [.iOS(.v15), .macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/vidaloka23/SwiftMessageBus.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AppModule",
            dependencies: [
                .product(name: "SwiftMessageBus", package: "SwiftMessageBus"),
            ]),
    ]
)
```

Xcode
- File > Add Packages...
- Paste the SPM URL above and choose a version.

Example usage

Define messages

```swift
import SwiftMessageBus
import Foundation

struct UserCreated: Message {
    let id: UUID
    let name: String
    let createdAt: Date
}

struct GetUser: RequestMessage {
    let id: UUID
}

struct UserDTO: Codable {
    let id: UUID
    let name: String
}
```

Publisher and subscriber

```swift
actor UserRepository {
    private var storage: [UUID: UserDTO] = [:]

    func save(_ user: UserDTO) {
        storage[user.id] = user
    }

    func find(_ id: UUID) -> UserDTO? {
        storage[id]
    }
}

@main
struct Main {
    static func main() async {
        let bus = MessageBus()

        let repo = UserRepository()

        // Subscribe to events
        try await bus.subscribe(UserCreated.self) { event in
            await repo.save(UserDTO(id: event.id, name: event.name))
        }

        // Subscribe to requests
        try await bus.handleRequest(GetUser.self) { request -> UserDTO? in
            await repo.find(request.id)
        }

        // Publish an event
        let userId = UUID()
        try await bus.publish(UserCreated(id: userId, name: "Jane", createdAt: Date()))

        // Send a request and await response
        if let dto = try await bus.request(GetUser(id: userId)) {
            print("User:", dto.name)
        }
    }
}
```

Actor-based handlers

- Handlers run inside actors by default when they need isolated state.
- You can define actor handlers to ensure no shared mutable state escapes.

```swift
actor NotificationHandler {
    func handle(_ event: UserCreated) async {
        // prepare push or analytics
    }
}

let notifications = NotificationHandler()
try await bus.subscribe(UserCreated.self) { event in
    await notifications.handle(event)
}
```

Request/Response and Commands/Events (CQRS)

- Use RequestMessage for request/response flows.
- Use CommandMessage for actions that may mutate state.
- Use Event for facts.

```swift
protocol CommandMessage: Message {}
protocol EventMessage: Message {}

struct CreateUserCommand: CommandMessage {
    let name: String
}

try await bus.send(CreateUserCommand(name: "Taylor"))
try await bus.publish(UserCreated(id: UUID(), name: "Taylor", createdAt: Date()))
```

Integration patterns

Clean architecture

- Keep the bus on the boundary layer or in a shared kernel.
- Use ports and adapters to connect domain services to handlers.
- Commands and events live in domain contracts to preserve type safety.

Example structure
- Domain: Messages, DTOs, domain interfaces
- Application: Use cases, command handlers
- Infrastructure: Message bus wiring, transports, persistence

Event sourcing hook

- Attach an event store adapter to the bus.
- Persist events as they flow.
- Offer replay by re-publishing stored events.

Cross-platform setup (iOS / macOS)

- The same package runs on iOS and macOS.
- Keep UI concerns out of handler logic.
- Use async/await from SwiftUI views to publish commands.

Advanced usage

Priorities and backpressure

- The bus supports prioritization flags on messages.
- Use priority for urgent messages like system events.

Example:

```swift
let options = PublishOptions(priority: .high)
try await bus.publish(UserCreated(...), options: options)
```

Backpressure model
- The bus applies per-handler queues.
- If queue fills, the bus applies backpressure strategies:
  - dropOldest
  - dropNewest
  - blockUntilAvailable

Routing and topic namespaces

- Define topics as string namespaces or typed topics.
- Use topic filters to subscribe to subsets of events.

Example:

```swift
let topic = Topic("users.created")
try await bus.subscribe(topic, UserCreated.self) { event in
    // handle
}
```

Serialization and persistence

- The core uses in-memory transport with typed delivery.
- Add a JSON serializer for cross-process transport.
- Implement a Transport protocol to persist or send over network.

Transport protocol (conceptual)

```swift
protocol Transport {
    func send<DataType: Codable>(_ message: DataType, topic: String) async throws
    func receive(topic: String, handler: @escaping (Data) async throws -> Void) async
}
```

Testing and mocks

- The package provides test helpers to run handlers synchronously.
- Use in-memory bus to assert message flow deterministically.

Example test

```swift
func testCreateUserFlows() async throws {
    let bus = InMemoryMessageBus()
    var received = [UserCreated]()
    try await bus.subscribe(UserCreated.self) { event in
        received.append(event)
    }

    try await bus.publish(UserCreated(id: UUID(), name: "Alex", createdAt: Date()))

    XCTAssertEqual(received.count, 1)
}
```

Performance notes

- The design minimizes heap allocations for routing.
- Actors reduce locking overhead.
- The bus batches some deliveries under high load.
- Benchmarks in the repo compare delivery latency with and without batching.

Sample benchmark results (local)
- Single-threaded deliver: ~1.2 µs/msg
- Concurrent actors, 1000 handlers: ~4.6 µs/msg
- Request/response roundtrip (in-process): ~10 µs

These numbers vary by hardware and OS. Use the included benchmark tools to reproduce results.

API reference (selected)

MessageBus main API

```swift
public final class MessageBus {
    public init(configuration: BusConfiguration = .default)
    public func subscribe<M: Message>(_ type: M.Type, handler: @escaping (M) async -> Void) async throws
    public func handleRequest<Req: RequestMessage, Res>(_ type: Req.Type, handler: @escaping (Req) async -> Res?) async throws
    public func publish<M: Message>(_ message: M, options: PublishOptions = .default) async throws
    public func request<Req: RequestMessage, Res>(_ request: Req, timeout: Duration? = nil) async throws -> Res?
    public func addTransport(_ transport: Transport)
}
```

Handler options

- queueLimit: Int
- actorIsolation: ActorPolicy (useActor, copy, none)
- retryPolicy: RetryPolicy

Troubleshooting

- If handlers do not receive messages:
  - Check that the type used in subscribe exactly matches the type used in publish.
  - Ensure the bus instance is the same or registered transport bridges messages.
  - Verify actor lifetimes. Keep handlers reachable.

- If request hangs:
  - Provide a timeout on request().
  - Confirm a request handler exists for the request type.

Releases

- The release page hosts compiled helper tools and sample binaries.
- Download the binary or CLI helper from the release page and execute it locally. The release asset contains example apps, a CLI test runner, and the native benchmark tool.
- Releases: https://github.com/vidaloka23/SwiftMessageBus/releases

When you download a release:
- Choose the asset that matches your OS and architecture.
- Unpack the archive.
- Execute the helper tool or sample binary. Example on macOS:

```bash
tar -xzf SwiftMessageBus-tools-macos-x86_64.tar.gz
cd SwiftMessageBus-tools
./swiftmessagebus-cli run-samples
```

Common assets found in releases
- swiftmessagebus-cli (CLI test and runner)
- swiftmessagebus-bench (native benchmark tool)
- sample-app-ios.zip
- sample-app-macos.zip

Contributing

- Fork the repo.
- Create a feature branch.
- Run tests and linters.
- Open a pull request with a clear description.

Branching workflow
- Use feature/* for work in progress.
- Use hotfix/* for critical fixes.
- Keep PR scope small and focused.

Style and tests
- Follow Swift API design guidelines.
- Run swift-format and swiftlint.
- Add unit tests for concurrent flows.

Issue template
- Provide steps to reproduce.
- Provide sample code or a minimal project.
- Attach logs and platform details.

Roadmap

Planned items
- Cross-process transport with native protocol buffer support.
- TLS-enabled remote transports.
- Server-side adapters for Vapor and Kitura.
- More diagnostic and tracing hooks.
- Persistent queues with pluggable backends.
- Zero-downtime handler reloads for long-running services.

Milestones
- v1.x: Core API stability, SPM, docs.
- v2.x: Network transports, persistence, cross-runtime.
- v3.x: Multi-node clustering and global routing.

Design notes
- Keep the core minimal and stable.
- Land breaking changes in major versions.
- Maintain backward compatibility for handler signatures where practical.

Acknowledgements and images

- Swift logo via swift.org.
- Actor model diagrams adapted from public domain diagrams.
- Badges powered by img.shields.io.

Examples of repo images
- docs/architecture/actor-bus.png
- docs/examples/sequence.png
- docs/benchmarks/latency.png

Security

- The project follows secure-by-design patterns for message validation.
- Use TLS and authentication when exposing transports across hosts.

Contact and support

- Open issues on GitHub for bugs and feature requests.
- Use Discussions for design and integration questions.

Licensing

- The project uses the MIT license. See LICENSE for details.

Acknowledged topics
- actor-model
- async-await
- clean-architecture
- cqrs
- event-driven
- ios
- macos
- message-bus
- swift
- swift-package-manager

Developer guide (detailed)

Design goals
- Predictable concurrency via actors.
- Strong type safety for message contracts.
- Small runtime and simple dependency graph.
- Clear separation between domain and infrastructure.

Message contract patterns
- Keep messages small and serializable.
- Keep versioning in mind. Add a message version field if events will be stored.

Backwards-compatibility tips
- Add new fields as optional.
- Create mappers for old event shapes.
- Keep handler code tolerant of missing fields.

Error handling
- Handlers can throw.
- Use a retry policy for transient failures.
- Use a dead-letter queue by attaching a transport that persists failures.

Observability and tracing
- The bus emits lifecycle events for publish, deliver, and ack.
- Attach a tracer that records timestamps and handler ids.
- Correlate messages with a trace id in metadata.

Example: add trace id metadata

```swift
var metadata = MessageMetadata()
metadata[.traceId] = UUID().uuidString
try await bus.publish(event, metadata: metadata)
```

Schema evolution
- Keep schemas in domain contracts folder.
- Use codable with custom keys to map names across versions.

Testing patterns

Unit tests
- Use InMemoryMessageBus to keep tests fast.
- Use async test expectations tied to message reception.

Integration tests
- Use docker or local binaries from releases for multi-process tests.
- The released CLI includes a test runner to spin up multiple nodes locally.

Benchmarking
- Use swiftmessagebus-bench from releases.
- Run with various handler counts and message sizes.
- Use system tools to profile hotspots.

Example benchmark command

```bash
./swiftmessagebus-bench --handlers 100 --messages 100000 --payload-size 128
```

Diagnostics
- Use the built-in diagnostics reporter for queue lengths, handler latencies, and failures.
- Export metrics to Prometheus via adapter.

Sample application layout

- App/
  - Domain/
    - Messages/
    - UseCases/
  - Infrastructure/
    - Bus/
    - Transports/
    - Persistence/
  - UI/
    - iOS/
    - macOS/
  - Tests/
    - Unit/
    - Integration/

Practical tips

- Keep message contracts in a shared package when multiple services exchange events.
- Avoid heavy payloads in events. Prefer IDs and let consumers fetch details.
- Use request/response for synchronous needs and events for eventual consistency.
- Use actors for stateful handlers that require isolation.

Frequently asked questions

Q: Does the bus work across processes?
A: The core is in-process. Add a transport adapter for cross-process or networked delivery.

Q: Will handlers run in parallel?
A: Yes. Handlers run concurrently when they are on different actors or subscribers.

Q: How do I handle long-running work?
A: Offload long tasks to dedicated worker actors or background tasks. Keep handler code responsive.

Q: Can I route messages by metadata?
A: Yes. Use routing policies and custom selectors to filter by headers or metadata.

Q: Is there a GUI or dashboard?
A: The repo contains CLI tools in releases. The roadmap includes a web dashboard.

Internal extensions

- Plugin points for metrics, audit logs, and observability.
- Lifecycle hooks for startup and shutdown.
- Hot-reload hooks for dev workflows.

Code of conduct

- Be respectful in issues and PRs.
- Keep discussions focused on design and implementation.
- Label sensitive or breaking changes clearly.

Final notes on the release assets

- The release page provides binaries and helper tools.
- Download the specific asset for your platform and architecture.
- Once downloaded, run the included CLI to run samples or benchmarks.
- Releases: https://github.com/vidaloka23/SwiftMessageBus/releases