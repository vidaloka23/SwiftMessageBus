import XCTest
@testable import SwiftMessageBus

final class MessagePayloadTests: XCTestCase {
    
    // MARK: - Test Types
    
    struct CustomPayload: MessagePayload {
        let id: String
        let name: String
        let value: Int
        let isActive: Bool
    }
    
    struct NestedPayload: MessagePayload {
        let user: UserPayload
        let metadata: [String: String]
    }
    
    struct UserPayload: MessagePayload {
        let id: String
        let email: String
        let age: Int?
    }
    
    // MARK: - Standard Type Conformance Tests
    
    func testStringConformance() {
        let payload: String = "test"
        XCTAssertTrue(type(of: payload) is MessagePayload.Type)
        
        // Test encoding/decoding
        let encoded = try! JSONEncoder().encode(payload)
        let decoded = try! JSONDecoder().decode(String.self, from: encoded)
        XCTAssertEqual(payload, decoded)
    }
    
    func testNumericConformance() {
        let intPayload: Int = 42
        let doublePayload: Double = 3.14
        let floatPayload: Float = 2.5
        
        XCTAssertTrue(type(of: intPayload) is MessagePayload.Type)
        XCTAssertTrue(type(of: doublePayload) is MessagePayload.Type)
        XCTAssertTrue(type(of: floatPayload) is MessagePayload.Type)
    }
    
    func testBoolConformance() {
        let payload: Bool = true
        XCTAssertTrue(type(of: payload) is MessagePayload.Type)
    }
    
    func testDataConformance() {
        let payload = Data([0x01, 0x02, 0x03])
        XCTAssertTrue(type(of: payload) is MessagePayload.Type)
    }
    
    func testDateConformance() {
        let payload = Date()
        XCTAssertTrue(type(of: payload) is MessagePayload.Type)
    }
    
    func testUUIDConformance() {
        let payload = UUID()
        XCTAssertTrue(type(of: payload) is MessagePayload.Type)
    }
    
    func testURLConformance() {
        let payload = URL(string: "https://example.com")!
        XCTAssertTrue(type(of: payload) is MessagePayload.Type)
    }
    
    // MARK: - Collection Conformance Tests
    
    func testArrayConformance() {
        let stringArray: [String] = ["a", "b", "c"]
        let intArray: [Int] = [1, 2, 3]
        
        XCTAssertTrue(type(of: stringArray) is MessagePayload.Type)
        XCTAssertTrue(type(of: intArray) is MessagePayload.Type)
        
        // Test encoding/decoding
        let encoded = try! JSONEncoder().encode(stringArray)
        let decoded = try! JSONDecoder().decode([String].self, from: encoded)
        XCTAssertEqual(stringArray, decoded)
    }
    
    func testDictionaryConformance() {
        let dict: [String: String] = ["key": "value", "foo": "bar"]
        XCTAssertTrue(type(of: dict) is MessagePayload.Type)
        
        let complexDict: [String: Int] = ["one": 1, "two": 2]
        XCTAssertTrue(type(of: complexDict) is MessagePayload.Type)
    }
    
    func testSetConformance() {
        let set: Set<String> = ["a", "b", "c"]
        XCTAssertTrue(type(of: set) is MessagePayload.Type)
    }
    
    func testOptionalConformance() {
        let optional1: String? = "test"
        let optional2: String? = nil
        let optional3: Int? = 42
        
        XCTAssertTrue(type(of: optional1) is MessagePayload.Type)
        XCTAssertTrue(type(of: optional2) is MessagePayload.Type)
        XCTAssertTrue(type(of: optional3) is MessagePayload.Type)
    }
    
    // MARK: - Empty Payload Tests
    
    func testEmptyPayload() {
        let payload = EmptyPayload()
        
        // Test encoding/decoding
        let encoded = try! JSONEncoder().encode(payload)
        let decoded = try! JSONDecoder().decode(EmptyPayload.self, from: encoded)
        XCTAssertEqual(payload, decoded)
    }
    
    // MARK: - Value Payload Tests
    
    func testValuePayloadWithString() {
        let payload = ValuePayload(value: "test-value")
        XCTAssertEqual(payload.value, "test-value")
        
        // Test encoding/decoding
        let encoded = try! JSONEncoder().encode(payload)
        let decoded = try! JSONDecoder().decode(ValuePayload<String>.self, from: encoded)
        XCTAssertEqual(payload, decoded)
    }
    
    func testValuePayloadWithInt() {
        let payload = ValuePayload(value: 42)
        XCTAssertEqual(payload.value, 42)
    }
    
    func testValuePayloadWithArray() {
        let payload = ValuePayload(value: [1, 2, 3])
        XCTAssertEqual(payload.value, [1, 2, 3])
    }
    
    // MARK: - Error Payload Tests
    
    func testErrorPayloadBasic() {
        let payload = ErrorPayload(
            code: "ERROR_001",
            message: "Something went wrong"
        )
        
        XCTAssertEqual(payload.code, "ERROR_001")
        XCTAssertEqual(payload.message, "Something went wrong")
        XCTAssertNil(payload.details)
    }
    
    func testErrorPayloadWithDetails() {
        let details = ["field": "email", "value": "invalid"]
        let payload = ErrorPayload(
            code: "VALIDATION_ERROR",
            message: "Validation failed",
            details: details
        )
        
        XCTAssertEqual(payload.code, "VALIDATION_ERROR")
        XCTAssertEqual(payload.message, "Validation failed")
        XCTAssertEqual(payload.details, details)
        
        // Test encoding/decoding
        let encoded = try! JSONEncoder().encode(payload)
        let decoded = try! JSONDecoder().decode(ErrorPayload.self, from: encoded)
        XCTAssertEqual(payload, decoded)
    }
    
    // MARK: - Custom Payload Tests
    
    func testCustomPayload() {
        let payload = CustomPayload(
            id: "123",
            name: "Test",
            value: 42,
            isActive: true
        )
        
        // Test encoding/decoding
        let encoded = try! JSONEncoder().encode(payload)
        let decoded = try! JSONDecoder().decode(CustomPayload.self, from: encoded)
        XCTAssertEqual(payload, decoded)
    }
    
    func testNestedPayload() {
        let user = UserPayload(id: "user-1", email: "test@example.com", age: 25)
        let payload = NestedPayload(
            user: user,
            metadata: ["source": "api", "version": "1.0"]
        )
        
        // Test encoding/decoding
        let encoded = try! JSONEncoder().encode(payload)
        let decoded = try! JSONDecoder().decode(NestedPayload.self, from: encoded)
        XCTAssertEqual(payload, decoded)
    }
    
    // MARK: - Sendable Conformance Tests
    
    func testSendableConformance() async {
        let payload = CustomPayload(
            id: "123",
            name: "Test",
            value: 42,
            isActive: true
        )
        
        // This should compile without warnings if Sendable is properly implemented
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                _ = payload.id
            }
            group.addTask {
                _ = payload.name
            }
        }
    }
}