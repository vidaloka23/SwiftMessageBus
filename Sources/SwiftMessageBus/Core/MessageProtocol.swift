import Foundation

/// Base protocol for all messages in the Swift Message Bus framework.
///
/// All messages must conform to this protocol to be routed through the message bus.
/// The protocol ensures messages have essential metadata for routing, tracking, and debugging.
///
/// ## Topics
///
/// ### Essential Properties
/// - ``id``
/// - ``timestamp``
/// - ``source``
/// - ``destination``
///
/// ### Metadata and Tracking
/// - ``metadata``
/// - ``correlationId``
public protocol MessageProtocol: Sendable {
    /// Unique identifier for this message instance.
    ///
    /// This ID is typically generated using `UUID().uuidString` to ensure uniqueness
    /// across the system. It can be used for debugging, logging, and message tracking.
    var id: String { get }
    
    /// Timestamp when the message was created.
    ///
    /// Used for ordering messages, calculating latency, and debugging timing issues.
    /// The timestamp is captured at message creation time.
    var timestamp: Date { get }
    
    /// The architectural layer that originated this message.
    ///
    /// Identifies which layer in the clean architecture created this message.
    /// This is used for routing validation and ensuring architectural boundaries
    /// are properly maintained.
    var source: Layer { get }
    
    /// Optional target layer for routing.
    ///
    /// When specified, the message will only be delivered to handlers in the target layer.
    /// If nil, the message is broadcast to all valid handlers based on routing rules.
    var destination: Layer? { get }
    
    /// Additional metadata as key-value pairs for cross-cutting concerns.
    ///
    /// Can be used for:
    /// - Tracing and correlation IDs
    /// - User context and authentication tokens
    /// - Feature flags and routing hints
    /// - Custom headers for plugins
    var metadata: [String: String] { get set }
    
    /// Optional correlation ID for tracking related messages in a flow.
    ///
    /// Used to trace a sequence of related messages through the system.
    /// All messages in the same business transaction or user flow should
    /// share the same correlation ID.
    var correlationId: String? { get set }
}

// MARK: - Default Implementations

public extension MessageProtocol {
    /// Generates a new unique message ID.
    ///
    /// - Returns: A new UUID string suitable for use as a message ID
    static func generateId() -> String {
        UUID().uuidString
    }
    
    /// Creates a correlation ID if one doesn't exist.
    ///
    /// - Parameter existingId: An optional existing correlation ID to use
    /// - Returns: The existing ID if provided, otherwise a new UUID string
    static func ensureCorrelationId(_ existingId: String? = nil) -> String {
        existingId ?? UUID().uuidString
    }
}