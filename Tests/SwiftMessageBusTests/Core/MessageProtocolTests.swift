import XCTest
@testable import SwiftMessageBus

final class MessageProtocolTests: XCTestCase {
    
    // MARK: - Test Types
    
    struct TestMessage: MessageProtocol {
        let id: String
        let timestamp: Date
        let source: Layer
        let destination: Layer?
        var metadata: [String: String]
        var correlationId: String?
        
        init(
            id: String = UUID().uuidString,
            timestamp: Date = Date(),
            source: Layer = .application,
            destination: Layer? = nil,
            metadata: [String: String] = [:],
            correlationId: String? = nil
        ) {
            self.id = id
            self.timestamp = timestamp
            self.source = source
            self.destination = destination
            self.metadata = metadata
            self.correlationId = correlationId
        }
    }
    
    // MARK: - Tests
    
    func testMessageProtocolConformance() {
        let message = TestMessage()
        
        XCTAssertFalse(message.id.isEmpty)
        XCTAssertNotNil(message.timestamp)
        XCTAssertEqual(message.source, .application)
        XCTAssertNil(message.destination)
        XCTAssertTrue(message.metadata.isEmpty)
        XCTAssertNil(message.correlationId)
    }
    
    func testMessageWithAllProperties() {
        let id = "test-123"
        let timestamp = Date()
        let source = Layer.presentation
        let destination = Layer.application
        let metadata = ["key": "value", "trace": "123"]
        let correlationId = "correlation-456"
        
        let message = TestMessage(
            id: id,
            timestamp: timestamp,
            source: source,
            destination: destination,
            metadata: metadata,
            correlationId: correlationId
        )
        
        XCTAssertEqual(message.id, id)
        XCTAssertEqual(message.timestamp, timestamp)
        XCTAssertEqual(message.source, source)
        XCTAssertEqual(message.destination, destination)
        XCTAssertEqual(message.metadata, metadata)
        XCTAssertEqual(message.correlationId, correlationId)
    }
    
    func testGenerateId() {
        let id1 = TestMessage.generateId()
        let id2 = TestMessage.generateId()
        
        XCTAssertFalse(id1.isEmpty)
        XCTAssertFalse(id2.isEmpty)
        XCTAssertNotEqual(id1, id2) // Should be unique
        
        // Should be valid UUID format
        XCTAssertNotNil(UUID(uuidString: id1))
        XCTAssertNotNil(UUID(uuidString: id2))
    }
    
    func testEnsureCorrelationId() {
        // Test with existing ID
        let existingId = "existing-123"
        let result1 = TestMessage.ensureCorrelationId(existingId)
        XCTAssertEqual(result1, existingId)
        
        // Test without existing ID
        let result2 = TestMessage.ensureCorrelationId(nil)
        XCTAssertFalse(result2.isEmpty)
        XCTAssertNotNil(UUID(uuidString: result2)) // Should be valid UUID
        
        // Test default parameter
        let result3 = TestMessage.ensureCorrelationId()
        XCTAssertFalse(result3.isEmpty)
        XCTAssertNotNil(UUID(uuidString: result3))
    }
    
    func testMetadataMutability() {
        var message = TestMessage()
        
        XCTAssertTrue(message.metadata.isEmpty)
        
        message.metadata["key1"] = "value1"
        message.metadata["key2"] = "value2"
        
        XCTAssertEqual(message.metadata.count, 2)
        XCTAssertEqual(message.metadata["key1"], "value1")
        XCTAssertEqual(message.metadata["key2"], "value2")
    }
    
    func testCorrelationIdMutability() {
        var message = TestMessage()
        
        XCTAssertNil(message.correlationId)
        
        message.correlationId = "new-correlation-id"
        XCTAssertEqual(message.correlationId, "new-correlation-id")
        
        message.correlationId = nil
        XCTAssertNil(message.correlationId)
    }
    
    func testSendableConformance() {
        // This test verifies that our test type can be used in concurrent contexts
        let message = TestMessage()
        
        Task {
            let capturedMessage = message
            XCTAssertEqual(capturedMessage.id, message.id)
        }
    }
}