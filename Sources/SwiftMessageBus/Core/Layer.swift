import Foundation

/// Architectural layers for message routing and clean architecture enforcement.
///
/// Layers represent logical boundaries in the application architecture,
/// enabling proper separation of concerns and dependency management.
///
/// ## Layer Hierarchy
///
/// The layers follow a strict hierarchy based on clean architecture principles:
///
/// ```
/// Presentation (UI)
///      ↓
/// Application (Use Cases)
///      ↓
/// Domain (Business Logic)
///      ↓
/// Infrastructure (Technical)
///      ↓
/// External (Third Party)
/// ```
///
/// ## Routing Rules
///
/// Messages can only flow in specific directions to maintain architectural integrity:
/// - **Presentation** → Application, Domain
/// - **Application** → Domain, Infrastructure
/// - **Domain** → Domain only (pure business logic)
/// - **Infrastructure** → External
/// - **External** → Infrastructure (callbacks)
///
/// ## Topics
///
/// ### Layer Types
/// - ``presentation``
/// - ``application``
/// - ``domain``
/// - ``infrastructure``
/// - ``external``
///
/// ### Routing
/// - ``canRoute(to:)``
public enum Layer: String, Codable, Sendable, CaseIterable, Equatable {
    /// Presentation layer - UI components, view controllers, SwiftUI views.
    ///
    /// Responsible for:
    /// - User interface rendering
    /// - User input handling
    /// - Presentation logic
    /// - View state management
    case presentation
    
    /// Application layer - Use cases, application services, orchestration.
    ///
    /// Responsible for:
    /// - Application flow orchestration
    /// - Use case implementation
    /// - Transaction management
    /// - Application-specific business rules
    case application
    
    /// Domain layer - Business logic, domain models, business rules.
    ///
    /// Responsible for:
    /// - Core business logic
    /// - Domain models and entities
    /// - Business rules and invariants
    /// - Domain events
    case domain
    
    /// Infrastructure layer - Data persistence, network clients, external services.
    ///
    /// Responsible for:
    /// - Database access
    /// - Network communication
    /// - File system operations
    /// - Third-party service integration
    case infrastructure
    
    /// External layer - Third-party integrations, system boundaries.
    ///
    /// Responsible for:
    /// - External API calls
    /// - Third-party SDKs
    /// - System services
    /// - Platform-specific implementations
    case external
}

// MARK: - Routing Rules

public extension Layer {
    /// Determines if a message can be routed from this layer to the destination layer.
    ///
    /// Routing rules enforce clean architecture principles by preventing
    /// inappropriate dependencies between layers.
    ///
    /// - Parameter destination: The target layer for the message
    /// - Returns: `true` if routing is allowed, `false` otherwise
    ///
    /// ## Example
    ///
    /// ```swift
    /// let canRoute = Layer.presentation.canRoute(to: .application) // true
    /// let invalid = Layer.domain.canRoute(to: .presentation) // false
    /// ```
    func canRoute(to destination: Layer) -> Bool {
        switch self {
        case .presentation:
            // Presentation can only go down to Application or Domain
            return destination == .application || destination == .domain
            
        case .application:
            // Application can go to Domain or Infrastructure
            return destination == .domain || destination == .infrastructure
            
        case .domain:
            // Domain can only talk to itself (pure business logic)
            return destination == .domain
            
        case .infrastructure:
            // Infrastructure can reach External services
            return destination == .external || destination == .infrastructure
            
        case .external:
            // External can callback to Infrastructure
            return destination == .infrastructure
        }
    }
    
    /// Returns all valid target layers from this layer.
    ///
    /// Useful for understanding which layers this layer can communicate with.
    ///
    /// - Returns: A set of layers that can receive messages from this layer
    var validTargets: Set<Layer> {
        Set(Layer.allCases.filter { canRoute(to: $0) })
    }
    
    /// Returns all layers that can route messages to this layer.
    ///
    /// Useful for understanding which layers can send messages to this layer.
    ///
    /// - Returns: A set of layers that can send messages to this layer
    var validSources: Set<Layer> {
        Set(Layer.allCases.filter { $0.canRoute(to: self) })
    }
    
    /// Provides a human-readable description of this layer's responsibilities.
    var description: String {
        switch self {
        case .presentation:
            return "User Interface and Presentation Logic"
        case .application:
            return "Application Services and Use Cases"
        case .domain:
            return "Business Logic and Domain Models"
        case .infrastructure:
            return "Technical Infrastructure and Persistence"
        case .external:
            return "External Systems and Third-Party Services"
        }
    }
}

// MARK: - Validation Helpers

public extension Layer {
    /// Validates that a routing path is allowed and returns an error if not.
    ///
    /// - Parameters:
    ///   - source: The source layer
    ///   - destination: The destination layer
    /// - Returns: An optional error message if routing is not allowed
    static func validateRouting(from source: Layer, to destination: Layer) -> String? {
        guard source.canRoute(to: destination) else {
            return "Invalid routing: \(source.rawValue) cannot send messages to \(destination.rawValue). " +
                   "Valid targets from \(source.rawValue): \(source.validTargets.map(\.rawValue).joined(separator: ", "))"
        }
        return nil
    }
}