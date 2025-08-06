# Contributing to Swift Message Bus

Thank you for your interest in contributing to Swift Message Bus! We welcome contributions from the community and are grateful for any help you can provide.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/SwiftMessageBus.git
   cd SwiftMessageBus
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/yourusername/SwiftMessageBus.git
   ```

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Code samples (if applicable)
- Environment details (OS, Swift version, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- A clear and descriptive title
- A detailed description of the proposed enhancement
- Use cases for the enhancement
- Examples of how it would be used

### Your First Code Contribution

Look for these tags in our issues:

- `good first issue` - Good for newcomers
- `help wanted` - We need help with these
- `documentation` - Help improve our docs

## Development Setup

### Prerequisites

- Swift 5.9 or later
- Xcode 15.0 or later (for macOS development)
- SwiftLint: `brew install swiftlint`
- swift-format: `brew install swift-format`

### Building the Project

```bash
# Build the project
swift build

# Run tests
swift test

# Run benchmarks
swift run -c release MessageBusBenchmarks

# Format code
make format

# Run linting
make lint
```

## Coding Standards

We use SwiftLint and swift-format with Google Swift Style Guide. Key guidelines:

- Use 2 spaces for indentation
- Maximum line length: 100 characters
- Document public APIs with DocC comments
- Prefer `let` over `var` when possible
- Use meaningful variable and function names

### Code Organization

```swift
// MARK: - Properties
private let messageQueue: MessageQueue

// MARK: - Public Methods
public func start() {
    // ...
}

// MARK: - Private Methods
private func processMessage() {
    // ...
}
```

## Testing Guidelines

- Maintain minimum 80% code coverage
- Write unit tests for all public APIs
- Follow Arrange-Act-Assert pattern
- Keep tests fast and isolated

```swift
func testSendMessage() async throws {
    // Given
    let message = TestMessage()
    
    // When
    let result = try await sut.send(message)
    
    // Then
    XCTAssertNotNil(result)
}
```

## Commit Message Guidelines

This project follows [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification.

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- **feat**: A new feature
- **fix**: A bug fix  
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **build**: Changes that affect the build system
- **ci**: Changes to CI configuration
- **chore**: Other changes that don't modify src or test

### Scope

The scope should be the name of the package/module affected:

- **core**: Core message bus functionality
- **macros**: Swift macro implementations
- **plugins**: Plugin system
- **routing**: Layer-based routing
- **tests**: Test infrastructure
- **bench**: Benchmarks
- **docs**: Documentation

### Examples

```bash
# Feature
feat(core): add query caching with TTL support

# Bug fix
fix(routing): prevent invalid layer transitions

# Breaking change
feat(api)!: change event handler to async/await

BREAKING CHANGE: Event handlers must now be async functions

# Documentation
docs: add plugin development guide

# Performance
perf(core): optimize message queue with ring buffer
```

### Breaking Changes

Breaking changes must be indicated:

1. By appending `!` after type/scope: `feat(api)!: change handler signature`
2. By adding `BREAKING CHANGE:` in the footer

## Pull Request Process

1. Ensure all commits follow the Conventional Commits specification
2. Update the README.md with details of changes if applicable
3. Add tests for any new functionality
4. Ensure all tests pass locally
5. Format your code using `make format`
6. The PR will be merged once approved by maintainers

### Pull Request Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass locally
- [ ] New tests added
- [ ] Coverage maintained or improved

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
```

## Setting Up Git Commit Template

To use the project's commit template:

```bash
git config --local commit.template .gitmessage
```

## Automated Changelog

The changelog is automatically generated from commit messages using GitHub Actions. Ensure your commits follow the convention for proper categorization.

## Questions?

If you have questions about contributing, please open a discussion or reach out to the maintainers.

Thank you for contributing to Swift Message Bus! 🚀
