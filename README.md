# SwiftMessageBus

A high-performance, type-safe message bus framework for Swift applications implementing CQRS and Event-Driven Architecture patterns.

## Overview

SwiftMessageBus provides a robust, actor-based messaging infrastructure designed for modern Swift applications. Built with Swift 5.9+ and leveraging structured concurrency, it offers thread-safe message passing with exceptional performance characteristics.

### Key Features

- **Type-Safe Messaging**: Generic message types with compile-time safety
- **CQRS Pattern**: Separate Commands, Queries, and Events with distinct handling
- **Actor-Based Concurrency**: Thread-safe by design using Swift actors
- **Layer-Based Routing**: Enforce clean architecture boundaries automatically
- **Plugin System**: Extensible middleware for logging, metrics, and more
- **High Performance**: Targets 100K+ messages/second with <1ms P99 latency
- **Multi-Platform**: iOS 16+, macOS 13+, watchOS 9+, tvOS 16+, Linux

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftMessageBus.git", from: "1.0.0")
]
```

## Quick Start

```swift
import SwiftMessageBus

// Initialize the message bus
let bus = MessageBus()

// Subscribe to events
await bus.subscribe(to: UserLoggedIn.self) { event in
    print("User logged in: \(event.payload.userId)")
}

// Publish events
let event = Event(source: .presentation, payload: UserLoggedIn(userId: "123"))
await bus.publish(event)

// Send commands
let command = Command(source: .application, payload: CreateUser(name: "John"))
let result = try await bus.send(command)

// Execute queries
let query = Query(source: .presentation, payload: GetUser(id: "123"))
let response = try await bus.query(query)
```

## Architecture

SwiftMessageBus follows a layered architecture approach:

- **Presentation Layer**: UI components and view controllers
- **Application Layer**: Use cases and application logic
- **Domain Layer**: Business logic and domain models
- **Infrastructure Layer**: Technical implementations
- **External Layer**: Third-party integrations

## Performance

Target performance metrics:
- Throughput: 100,000+ messages/second
- P99 Latency: <1ms
- Memory: <5MB for 1000 subscribers

## Documentation

Full documentation and examples coming soon.

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## License

SwiftMessageBus is released under the MIT License. See [LICENSE](LICENSE) for details.