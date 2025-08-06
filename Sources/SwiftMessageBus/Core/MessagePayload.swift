import Foundation

/// Protocol constraint for message payload types.
///
/// All payload types must conform to this protocol to ensure they can be
/// serialized for transport and are safe for concurrent access.
///
/// ## Conformance
///
/// To make your custom type usable as a message payload:
///
/// ```swift
/// struct UserCreatedPayload: MessagePayload {
///     let userId: String
///     let email: String
///     let createdAt: Date
/// }
/// ```
///
/// ## Built-in Conformances
///
/// The following standard library types already conform to `MessagePayload`:
/// - Basic types: `String`, `Int`, `Double`, `Bool`
/// - Foundation types: `Data`, `Date`, `UUID`, `URL`
/// - Collections: `Array` and `Dictionary` (when their elements conform)
/// - Optionals: `Optional` (when the wrapped type conforms)
public protocol MessagePayload: Codable, Sendable, Equatable {}

// MARK: - Standard Library Conformances

// Basic types
extension String: MessagePayload {}
extension Int: MessagePayload {}
extension Int8: MessagePayload {}
extension Int16: MessagePayload {}
extension Int32: MessagePayload {}
extension Int64: MessagePayload {}
extension UInt: MessagePayload {}
extension UInt8: MessagePayload {}
extension UInt16: MessagePayload {}
extension UInt32: MessagePayload {}
extension UInt64: MessagePayload {}
extension Double: MessagePayload {}
extension Float: MessagePayload {}
extension Bool: MessagePayload {}

// Foundation types
extension Data: MessagePayload {}
extension Date: MessagePayload {}
extension UUID: MessagePayload {}
extension URL: MessagePayload {}
extension Decimal: MessagePayload {}

// Collections
extension Array: MessagePayload where Element: MessagePayload {}
extension Dictionary: MessagePayload where Key == String, Value: MessagePayload {}
extension Set: MessagePayload where Element: MessagePayload {}

// Optionals
extension Optional: MessagePayload where Wrapped: MessagePayload {}

// MARK: - Empty Payload

/// An empty message payload for messages that don't carry data.
///
/// Useful for signals, triggers, or commands that don't require additional information.
///
/// ## Example
///
/// ```swift
/// let heartbeat = Event(
///     source: .infrastructure,
///     payload: EmptyPayload()
/// )
/// ```
public struct EmptyPayload: MessagePayload {
  public init() {}
}

// MARK: - Common Payload Types

/// A generic payload containing a single value.
///
/// Useful for simple messages that carry a single piece of data.
///
/// ## Example
///
/// ```swift
/// let userId = ValuePayload(value: "user-123")
/// let count = ValuePayload(value: 42)
/// ```
public struct ValuePayload<T: MessagePayload>: MessagePayload {
  public let value: T

  public init(value: T) {
    self.value = value
  }
}

/// A generic error payload for error messages.
///
/// Used to communicate errors through the message bus.
///
/// ## Example
///
/// ```swift
/// let error = ErrorPayload(
///     code: "VALIDATION_ERROR",
///     message: "Email address is invalid",
///     details: ["field": "email", "value": "not-an-email"]
/// )
/// ```
public struct ErrorPayload: MessagePayload {
  public let code: String
  public let message: String
  public let details: [String: String]?

  public init(code: String, message: String, details: [String: String]? = nil) {
    self.code = code
    self.message = message
    self.details = details
  }
}
