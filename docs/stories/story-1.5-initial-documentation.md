# Story 1.5: Create Initial Documentation

**Status**: Draft
**Epic**: 1 - Core Foundation and Package Setup
**Priority**: P0 - Critical
**Estimated Points**: 3
**Dependencies**: Stories 1.1-1.3 (Package and types must exist)

## Story

**As a** new user  
**I want** clear documentation  
**So that** I can quickly understand and use the framework

## Acceptance Criteria

- [ ] README.md with comprehensive installation instructions
- [ ] Quick start example that works in <3 minutes
- [ ] API documentation structure established
- [ ] Contributing guidelines (CONTRIBUTING.md)
- [ ] Architecture overview with diagram
- [ ] Build status badges functioning
- [ ] License clearly stated
- [ ] Contact/support information provided

## Dev Notes

### Documentation Philosophy
- Focus on getting users productive quickly
- Provide clear, runnable examples
- Explain the "why" not just the "how"
- Keep initial docs concise but complete
- Link to more detailed docs for advanced topics

### README Structure
1. Project banner/logo (if available)
2. Badges (build, coverage, version, license)
3. One-paragraph description
4. Key features list
5. Installation instructions
6. Quick start example
7. Architecture overview
8. Documentation links
9. Contributing info
10. License

## Tasks

### Development Tasks
- [ ] Create comprehensive README.md
- [ ] Write quick start example code
- [ ] Create CONTRIBUTING.md with guidelines
- [ ] Add architecture diagram (ASCII or Mermaid)
- [ ] Set up documentation folder structure
- [ ] Add code of conduct (CODE_OF_CONDUCT.md)
- [ ] Create issue templates

### README.md Implementation

```markdown
# Swift Message Bus

[![CI Status](https://github.com/yourusername/SwiftMessageBus/workflows/CI/badge.svg)](https://github.com/yourusername/SwiftMessageBus/actions)
[![codecov](https://codecov.io/gh/yourusername/SwiftMessageBus/branch/main/graph/badge.svg)](https://codecov.io/gh/yourusername/SwiftMessageBus)
[![Swift Version](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20watchOS%20|%20tvOS%20|%20Linux-lightgray.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A high-performance, type-safe message bus framework for Swift that eliminates boilerplate while maintaining sub-millisecond latency. Built with Swift's actor model for guaranteed thread safety and supporting clean architecture through layer-based routing.

## ✨ Key Features

- 🚀 **Blazing Fast**: 100K+ messages/second with <1ms P99 latency
- 🔒 **Type Safe**: Complete compile-time type safety with zero runtime casting
- 🎭 **Actor-Based**: Built on Swift actors for guaranteed thread safety
- 🔌 **Extensible**: Rich plugin system for middleware, logging, metrics, and more
- 🏗️ **Clean Architecture**: Built-in layer-based routing for architectural boundaries
- 📦 **Zero Dependencies**: Pure Swift with minimal external dependencies
- 🧩 **CQRS Ready**: First-class support for Commands, Queries, and Events

## 📦 Installation

### Swift Package Manager

Add SwiftMessageBus to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftMessageBus.git", from: "1.0.0")
]
```

Then add to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["SwiftMessageBus"]
)
```

## 🚀 Quick Start

Get up and running in less than 3 minutes:

```swift
import SwiftMessageBus

// 1. Define your message payloads
struct CreateUserPayload: MessagePayload {
    let name: String
    let email: String
}

struct UserCreatedPayload: MessagePayload {
    let userId: String
    let name: String
}

// 2. Create the message bus
let messageBus = MessageBus()

// 3. Register handlers
await messageBus.handleCommand(CreateUserPayload.self) { command in
    // Process the command
    let userId = UUID().uuidString
    print("Creating user: \(command.payload.name)")
    
    // Publish an event
    let event = Event(
        source: .domain,
        payload: UserCreatedPayload(userId: userId, name: command.payload.name)
    )
    await messageBus.publish(event)
    
    return CommandResult.success
}

// 4. Subscribe to events
await messageBus.subscribe(to: UserCreatedPayload.self) { event in
    print("User created: \(event.payload.userId)")
}

// 5. Send a command
let command = Command(
    source: .presentation,
    destination: .application,
    payload: CreateUserPayload(name: "John Doe", email: "john@example.com")
)

let result = try await messageBus.send(command)
print("Command result: \(result)")
```

## 🏗️ Architecture Overview

```
┌─────────────────┐
│  Presentation   │ ← SwiftUI/UIKit Views
├─────────────────┤
│  Application    │ ← Use Cases/Services
├─────────────────┤
│    Domain       │ ← Business Logic
├─────────────────┤
│ Infrastructure  │ ← Database/Network
└─────────────────┘
        ↓
   Message Bus     ← Routes messages between layers
```

The framework enforces clean architecture through layer-based routing:
- Messages flow downward through layers
- Responses flow back up
- Cross-layer communication is validated

## 📚 Documentation

- [API Documentation](https://yourusername.github.io/SwiftMessageBus/)
- [Architecture Guide](docs/architecture.md)
- [Plugin Development](docs/plugins.md)
- [Performance Tuning](docs/performance.md)
- [Migration Guides](docs/migration/)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

Quick contribution checklist:
- Fork the repository
- Create a feature branch
- Write tests for your changes
- Ensure all tests pass
- Submit a pull request

## 📊 Performance

Benchmarked on M1 MacBook Pro:

| Metric | Value |
|--------|-------|
| Throughput | 150K msgs/sec |
| P50 Latency | 0.2ms |
| P99 Latency | 0.8ms |
| Memory (1K subscribers) | 3.2MB |

## 🛣️ Roadmap

- [x] Core message bus implementation
- [x] Plugin system
- [x] Performance validation
- [ ] Swift macros for boilerplate reduction (v1.1)
- [ ] Distributed messaging (v1.2)
- [ ] Persistence plugins (v1.2)

## 📄 License

SwiftMessageBus is released under the MIT License. See [LICENSE](LICENSE) for details.

## 💬 Support

- 🐛 [Report bugs](https://github.com/yourusername/SwiftMessageBus/issues)
- 💡 [Request features](https://github.com/yourusername/SwiftMessageBus/issues)
- 💬 [Discussions](https://github.com/yourusername/SwiftMessageBus/discussions)
- 📧 Contact: your.email@example.com
```

### CONTRIBUTING.md Template

```markdown
# Contributing to Swift Message Bus

Thank you for your interest in contributing to Swift Message Bus! 

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

- Check existing issues first
- Use the bug report template
- Include reproduction steps
- Provide system information

### Suggesting Features

- Check the roadmap and existing issues
- Use the feature request template
- Explain the use case
- Consider implementation approach

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`swift test`)
5. Run SwiftLint (`swiftlint`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Development Setup

1. Clone the repository
2. Open in Xcode or your preferred editor
3. Build: `swift build`
4. Test: `swift test`
5. Benchmark: `swift run -c release MessageBusBenchmarks`

### Testing Guidelines

- Write unit tests for all new code
- Maintain >80% code coverage
- Include integration tests for complex features
- Test on multiple platforms when possible

### Code Style

We use SwiftLint with strict mode. Key points:
- 4 spaces for indentation
- Max line length: 120 characters
- Use meaningful variable names
- Document public APIs with DocC comments

### Commit Messages

Follow conventional commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `test:` Test additions or changes
- `perf:` Performance improvements
- `refactor:` Code refactoring

## Questions?

Feel free to open a discussion or reach out to the maintainers.
```

### Testing Tasks
- [ ] Verify README renders correctly on GitHub
- [ ] Test quick start example actually works
- [ ] Ensure all links are valid
- [ ] Verify badges display correctly
- [ ] Test contributing workflow

## Definition of Done

- [ ] README.md is comprehensive and clear
- [ ] Quick start example tested and works
- [ ] CONTRIBUTING.md provides clear guidelines
- [ ] All documentation renders correctly
- [ ] Links and badges functional
- [ ] New user can start using framework in <3 minutes

## Dev Agent Record

### Agent Model Used
- 

### Debug Log References
- 

### Completion Notes
- 

### File List
- [ ] README.md (updated)
- [ ] CONTRIBUTING.md
- [ ] CODE_OF_CONDUCT.md
- [ ] .github/ISSUE_TEMPLATE/bug_report.md
- [ ] .github/ISSUE_TEMPLATE/feature_request.md
- [ ] docs/architecture.md (placeholder)
- [ ] docs/plugins.md (placeholder)
- [ ] docs/performance.md (placeholder)

### Change Log
- 