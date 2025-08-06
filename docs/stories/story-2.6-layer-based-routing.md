# Story 2.6: Implement Layer-Based Routing

**Status**: Draft
**Epic**: 2 - Message Bus Actor Implementation
**Priority**: P1 - High
**Estimated Points**: 4
**Dependencies**: Stories 2.1-2.5 (Core message bus and handler registration)

## Story

**As a** developer  
**I want** automatic layer-based routing enforcement  
**So that** I can maintain clean architecture boundaries

## Acceptance Criteria

- [ ] Layer routing rules enforced for all message types
- [ ] Presentation → Application/Domain allowed
- [ ] Application → Domain/Infrastructure allowed
- [ ] Domain → Domain only (no external dependencies)
- [ ] Infrastructure → External allowed
- [ ] External → Infrastructure callback allowed
- [ ] Routing violations throw descriptive errors
- [ ] Bypass option for specific use cases
- [ ] Routing matrix visualization support

## Dev Notes

### Routing Strategy
- Enforce at message publication/send time
- Allow configuration overrides for special cases
- Track routing violations in metrics
- Support dynamic routing rules

### Layer Hierarchy
```
Presentation (UI)
    ↓
Application (Use Cases)
    ↓
Domain (Business Logic)
    ↓
Infrastructure (Technical)
    ↓
External (Third Party)
```

## Tasks

### Development Tasks
- [ ] Implement Layer routing rules engine
- [ ] Add routing validation to all message operations
- [ ] Create routing bypass mechanism
- [ ] Implement routing metrics collection
- [ ] Add routing visualization support
- [ ] Create custom routing rule support
- [ ] Implement routing middleware hooks
- [ ] Add routing migration utilities

### Implementation Details

#### Layer Routing Rules
```swift
// Layer+Routing.swift

extension Layer {
    /// Determines if this layer can route messages to the target layer
    public func canRoute(to target: Layer) -> Bool {
        switch self {
        case .presentation:
            // Presentation can only go down to Application or Domain
            return target == .application || target == .domain
            
        case .application:
            // Application can go to Domain or Infrastructure
            return target == .domain || target == .infrastructure
            
        case .domain:
            // Domain can only talk to itself (pure business logic)
            return target == .domain
            
        case .infrastructure:
            // Infrastructure can reach External services
            return target == .external || target == .infrastructure
            
        case .external:
            // External can callback to Infrastructure
            return target == .infrastructure
        }
    }
    
    /// Returns all valid target layers from this layer
    public var validTargets: Set<Layer> {
        Set(Layer.allCases.filter { canRoute(to: $0) })
    }
    
    /// Returns all layers that can route to this layer
    public var validSources: Set<Layer> {
        Set(Layer.allCases.filter { $0.canRoute(to: self) })
    }
    
    /// Detailed routing error message
    public func routingError(to target: Layer) -> String {
        """
        Layer routing violation: \(self) → \(target)
        
        Rule violated: \(self.rawValue) cannot send messages to \(target.rawValue)
        Valid targets from \(self.rawValue): \(validTargets.map(\.rawValue).joined(separator: ", "))
        
        Architecture principle: \(routingPrinciple)
        """
    }
    
    private var routingPrinciple: String {
        switch self {
        case .presentation:
            return "UI layer should only orchestrate through Application or query Domain"
        case .application:
            return "Application coordinates between Domain logic and Infrastructure"
        case .domain:
            return "Domain must remain pure and isolated from external concerns"
        case .infrastructure:
            return "Infrastructure handles technical concerns and external integrations"
        case .external:
            return "External services can only callback through Infrastructure"
        }
    }
}
```

#### Enhanced Routing Validation
```swift
// In MessageBusActor.swift

private let routingConfiguration: RoutingConfiguration

// MARK: - Routing Validation

private func validateRouting(
    from source: Layer,
    to destination: Layer?,
    messageType: String,
    bypassRouting: Bool = false
) throws {
    // Skip validation if bypassed
    if bypassRouting && configuration.allowRoutingBypass {
        metrics.routingBypasses += 1
        if configuration.enableTracing {
            logRoutingBypass(from: source, to: destination, type: messageType)
        }
        return
    }
    
    // No destination means broadcast - validate against all valid targets
    guard let destination = destination else {
        // Broadcasting is allowed within valid targets
        return
    }
    
    // Check standard routing rules
    guard source.canRoute(to: destination) else {
        metrics.routingViolations += 1
        
        // Check for custom rules
        if let customRule = routingConfiguration.customRules.first(where: { 
            $0.matches(source: source, destination: destination) 
        }) {
            if customRule.isAllowed {
                metrics.customRoutingMatches += 1
                return // Custom rule allows this routing
            }
        }
        
        throw MessageBusError.routingViolation(
            from: source,
            to: destination,
            message: source.routingError(to: destination)
        )
    }
    
    metrics.validRoutings += 1
}

// Enhanced publish with routing validation
func publish<T: MessagePayload>(_ event: Event<T>) async -> Int {
    do {
        try validateRouting(
            from: event.source,
            to: event.destination,
            messageType: "Event<\(T.self)>",
            bypassRouting: event.metadata["bypass-routing"] == "true"
        )
    } catch {
        // For events, log error but continue (events are fire-and-forget)
        logRoutingError(error, for: event)
        if configuration.strictRoutingEnforcement {
            return 0 // Don't publish if strict mode
        }
    }
    
    // Continue with normal publishing...
    return await publishImplementation(event)
}

// Enhanced send with routing validation
func send<T: MessagePayload>(_ command: Command<T>) async throws -> CommandResult {
    try validateRouting(
        from: command.source,
        to: command.destination,
        messageType: "Command<\(T.self)>",
        bypassRouting: command.metadata["bypass-routing"] == "true"
    )
    
    // Continue with normal command handling...
    return try await sendImplementation(command)
}

// Enhanced query with routing validation
func query<T: MessagePayload, R: MessagePayload>(_ query: Query<T, R>) async throws -> Response<R> {
    try validateRouting(
        from: query.source,
        to: query.destination,
        messageType: "Query<\(T.self), \(R.self)>",
        bypassRouting: query.metadata["bypass-routing"] == "true"
    )
    
    // Continue with normal query processing...
    return try await queryImplementation(query)
}
```

#### Routing Configuration
```swift
// RoutingConfiguration.swift

public struct RoutingConfiguration: Sendable {
    public let strictEnforcement: Bool
    public let allowBypass: Bool
    public let customRules: [CustomRoutingRule]
    public let logViolations: Bool
    
    public static let `default` = RoutingConfiguration(
        strictEnforcement: true,
        allowBypass: false,
        customRules: [],
        logViolations: true
    )
    
    public static let relaxed = RoutingConfiguration(
        strictEnforcement: false,
        allowBypass: true,
        customRules: [],
        logViolations: true
    )
}

public struct CustomRoutingRule: Sendable {
    public let id: String
    public let source: Layer?
    public let destination: Layer?
    public let messageTypePattern: String?
    public let isAllowed: Bool
    public let reason: String
    
    func matches(source: Layer, destination: Layer) -> Bool {
        let sourceMatch = self.source == nil || self.source == source
        let destMatch = self.destination == nil || self.destination == destination
        return sourceMatch && destMatch
    }
}
```

#### Routing Metrics and Visualization
```swift
// RoutingMetrics.swift

public struct RoutingMetrics: Sendable {
    public var validRoutings: Int = 0
    public var routingViolations: Int = 0
    public var routingBypasses: Int = 0
    public var customRoutingMatches: Int = 0
    
    // Track routing patterns
    private(set) var routingMatrix: [String: Int] = [:]
    
    mutating func recordRouting(from: Layer, to: Layer) {
        let key = "\(from.rawValue)→\(to.rawValue)"
        routingMatrix[key, default: 0] += 1
    }
    
    public var violationRate: Double {
        let total = validRoutings + routingViolations
        guard total > 0 else { return 0 }
        return Double(routingViolations) / Double(total)
    }
}

// Routing Visualizer
public struct RoutingVisualizer {
    public static func generateMatrix(from metrics: RoutingMetrics) -> String {
        var output = "Layer Routing Matrix:\n\n"
        output += "From → To | Count\n"
        output += "----------|------\n"
        
        for (route, count) in metrics.routingMatrix.sorted(by: { $0.value > $1.value }) {
            output += "\(route) | \(count)\n"
        }
        
        output += "\nViolation Rate: \(String(format: "%.2f%%", metrics.violationRate * 100))\n"
        output += "Bypasses: \(metrics.routingBypasses)\n"
        
        return output
    }
    
    public static func generateMermaidDiagram(from metrics: RoutingMetrics) -> String {
        var output = "graph TD\n"
        
        for (route, count) in metrics.routingMatrix {
            let components = route.split(separator: "→")
            if components.count == 2 {
                let from = components[0]
                let to = components[1]
                let width = min(max(1, count / 100), 10)
                output += "    \(from) -->|\(count)| \(to)\n"
                output += "    linkStyle \(from)\(to) stroke-width:\(width)px\n"
            }
        }
        
        return output
    }
}
```

#### Routing Middleware
```swift
// RoutingMiddleware.swift

public protocol RoutingMiddleware {
    func shouldAllowRouting(from: Layer, to: Layer, context: RoutingContext) async -> Bool
    func onRoutingViolation(from: Layer, to: Layer, context: RoutingContext) async
}

public struct RoutingContext: Sendable {
    public let messageType: String
    public let correlationId: String
    public let metadata: [String: String]
    public let timestamp: Date
}

// In MessageBusActor
private var routingMiddleware: [any RoutingMiddleware] = []

func addRoutingMiddleware(_ middleware: any RoutingMiddleware) {
    routingMiddleware.append(middleware)
}

private func checkMiddleware(from: Layer, to: Layer, context: RoutingContext) async -> Bool {
    for middleware in routingMiddleware {
        if await middleware.shouldAllowRouting(from: from, to: to, context: context) {
            return true
        }
    }
    return false
}
```

### Testing Tasks
- [ ] Test valid routing paths
- [ ] Test routing violation detection
- [ ] Test routing bypass mechanism
- [ ] Test custom routing rules
- [ ] Test routing metrics collection
- [ ] Test routing visualization
- [ ] Test middleware integration
- [ ] Test strict vs relaxed modes
- [ ] Test concurrent routing validation

### Test Scenarios
```swift
// Test valid routing
func testValidLayerRouting() async throws {
    let bus = MessageBus()
    
    // Presentation → Application (valid)
    let command = Command(
        source: .presentation,
        destination: .application,
        payload: TestPayload()
    )
    
    let result = try await bus.send(command)
    XCTAssertNotNil(result)
}

// Test routing violation
func testRoutingViolation() async throws {
    let bus = MessageBus()
    
    // Domain → Presentation (invalid)
    let command = Command(
        source: .domain,
        destination: .presentation,
        payload: TestPayload()
    )
    
    await XCTAssertThrowsError(try await bus.send(command)) { error in
        guard case MessageBusError.routingViolation(let from, let to, _) = error else {
            XCTFail("Expected routing violation error")
            return
        }
        XCTAssertEqual(from, .domain)
        XCTAssertEqual(to, .presentation)
    }
}

// Test routing bypass
func testRoutingBypass() async throws {
    let config = BusConfiguration(allowRoutingBypass: true)
    let bus = MessageBus(configuration: config)
    
    // Domain → Infrastructure (normally invalid)
    let command = Command(
        source: .domain,
        destination: .infrastructure,
        payload: TestPayload(),
        metadata: ["bypass-routing": "true"]
    )
    
    // Should succeed with bypass
    let result = try await bus.send(command)
    XCTAssertNotNil(result)
    
    // Verify bypass was recorded
    let metrics = await bus.getRoutingMetrics()
    XCTAssertEqual(metrics.routingBypasses, 1)
}

// Test custom routing rules
func testCustomRoutingRule() async throws {
    let customRule = CustomRoutingRule(
        id: "special-case",
        source: .domain,
        destination: .infrastructure,
        messageTypePattern: nil,
        isAllowed: true,
        reason: "Special monitoring case"
    )
    
    let routingConfig = RoutingConfiguration(
        strictEnforcement: true,
        allowBypass: false,
        customRules: [customRule],
        logViolations: true
    )
    
    let bus = MessageBus(routingConfiguration: routingConfig)
    
    // Domain → Infrastructure (allowed by custom rule)
    let event = Event(
        source: .domain,
        destination: .infrastructure,
        payload: TestPayload()
    )
    
    let count = await bus.publish(event)
    XCTAssertGreaterThan(count, 0)
}
```

## Definition of Done

- [ ] Layer routing rules implemented
- [ ] Routing validation integrated
- [ ] Bypass mechanism functional
- [ ] Custom rules support complete
- [ ] Routing metrics tracking
- [ ] Visualization tools ready
- [ ] Middleware hooks working
- [ ] All tests passing
- [ ] Documentation updated

## Dev Agent Record

### Agent Model Used
- 

### Debug Log References
- 

### Completion Notes
- 

### File List
- [ ] Sources/SwiftMessageBus/Core/Layer+Routing.swift
- [ ] Sources/SwiftMessageBus/Core/MessageBusActor.swift (updated)
- [ ] Sources/SwiftMessageBus/Core/RoutingConfiguration.swift
- [ ] Sources/SwiftMessageBus/Core/RoutingMetrics.swift
- [ ] Sources/SwiftMessageBus/Core/RoutingVisualizer.swift
- [ ] Sources/SwiftMessageBus/Core/RoutingMiddleware.swift
- [ ] Tests/SwiftMessageBusTests/LayerRoutingTests.swift
- [ ] Tests/SwiftMessageBusTests/RoutingBypassTests.swift
- [ ] Tests/SwiftMessageBusTests/CustomRoutingTests.swift

### Change Log
- 