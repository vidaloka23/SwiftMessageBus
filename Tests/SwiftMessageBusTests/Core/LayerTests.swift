import XCTest

@testable import SwiftMessageBus

final class LayerTests: XCTestCase {
  // MARK: - Basic Tests

  func testLayerRawValues() {
    XCTAssertEqual(Layer.presentation.rawValue, "presentation")
    XCTAssertEqual(Layer.application.rawValue, "application")
    XCTAssertEqual(Layer.domain.rawValue, "domain")
    XCTAssertEqual(Layer.infrastructure.rawValue, "infrastructure")
    XCTAssertEqual(Layer.external.rawValue, "external")
  }

  func testAllCases() {
    let allLayers = Layer.allCases
    XCTAssertEqual(allLayers.count, 5)
    XCTAssertTrue(allLayers.contains(.presentation))
    XCTAssertTrue(allLayers.contains(.application))
    XCTAssertTrue(allLayers.contains(.domain))
    XCTAssertTrue(allLayers.contains(.infrastructure))
    XCTAssertTrue(allLayers.contains(.external))
  }

  func testDescription() {
    XCTAssertEqual(Layer.presentation.description, "User Interface and Presentation Logic")
    XCTAssertEqual(Layer.application.description, "Application Services and Use Cases")
    XCTAssertEqual(Layer.domain.description, "Business Logic and Domain Models")
    XCTAssertEqual(Layer.infrastructure.description, "Technical Infrastructure and Persistence")
    XCTAssertEqual(Layer.external.description, "External Systems and Third-Party Services")
  }

  // MARK: - Routing Rules Tests

  func testPresentationLayerRouting() {
    let layer = Layer.presentation

    // Allowed routes
    XCTAssertTrue(layer.canRoute(to: .application))
    XCTAssertTrue(layer.canRoute(to: .domain))

    // Disallowed routes
    XCTAssertFalse(layer.canRoute(to: .presentation))
    XCTAssertFalse(layer.canRoute(to: .infrastructure))
    XCTAssertFalse(layer.canRoute(to: .external))
  }

  func testApplicationLayerRouting() {
    let layer = Layer.application

    // Allowed routes
    XCTAssertTrue(layer.canRoute(to: .domain))
    XCTAssertTrue(layer.canRoute(to: .infrastructure))

    // Disallowed routes
    XCTAssertFalse(layer.canRoute(to: .presentation))
    XCTAssertFalse(layer.canRoute(to: .application))
    XCTAssertFalse(layer.canRoute(to: .external))
  }

  func testDomainLayerRouting() {
    let layer = Layer.domain

    // Allowed routes (only to itself)
    XCTAssertTrue(layer.canRoute(to: .domain))

    // Disallowed routes
    XCTAssertFalse(layer.canRoute(to: .presentation))
    XCTAssertFalse(layer.canRoute(to: .application))
    XCTAssertFalse(layer.canRoute(to: .infrastructure))
    XCTAssertFalse(layer.canRoute(to: .external))
  }

  func testInfrastructureLayerRouting() {
    let layer = Layer.infrastructure

    // Allowed routes
    XCTAssertTrue(layer.canRoute(to: .infrastructure))
    XCTAssertTrue(layer.canRoute(to: .external))

    // Disallowed routes
    XCTAssertFalse(layer.canRoute(to: .presentation))
    XCTAssertFalse(layer.canRoute(to: .application))
    XCTAssertFalse(layer.canRoute(to: .domain))
  }

  func testExternalLayerRouting() {
    let layer = Layer.external

    // Allowed routes (callback to infrastructure)
    XCTAssertTrue(layer.canRoute(to: .infrastructure))

    // Disallowed routes
    XCTAssertFalse(layer.canRoute(to: .presentation))
    XCTAssertFalse(layer.canRoute(to: .application))
    XCTAssertFalse(layer.canRoute(to: .domain))
    XCTAssertFalse(layer.canRoute(to: .external))
  }

  // MARK: - Valid Targets Tests

  func testValidTargets() {
    XCTAssertEqual(Layer.presentation.validTargets, [.application, .domain])
    XCTAssertEqual(Layer.application.validTargets, [.domain, .infrastructure])
    XCTAssertEqual(Layer.domain.validTargets, [.domain])
    XCTAssertEqual(Layer.infrastructure.validTargets, [.infrastructure, .external])
    XCTAssertEqual(Layer.external.validTargets, [.infrastructure])
  }

  // MARK: - Valid Sources Tests

  func testValidSources() {
    // Who can send to presentation? Nobody
    XCTAssertTrue(Layer.presentation.validSources.isEmpty)

    // Who can send to application? Presentation
    XCTAssertEqual(Layer.application.validSources, [.presentation])

    // Who can send to domain? Presentation, Application, and Domain itself
    XCTAssertEqual(Layer.domain.validSources, Set([.presentation, .application, .domain]))

    // Who can send to infrastructure? Application, Infrastructure itself, and External
    XCTAssertEqual(
      Layer.infrastructure.validSources, Set([.application, .infrastructure, .external]))

    // Who can send to external? Infrastructure
    XCTAssertEqual(Layer.external.validSources, [.infrastructure])
  }

  // MARK: - Validation Helper Tests

  func testValidateRoutingSuccess() {
    XCTAssertNil(Layer.validateRouting(from: .presentation, to: .application))
    XCTAssertNil(Layer.validateRouting(from: .application, to: .domain))
    XCTAssertNil(Layer.validateRouting(from: .infrastructure, to: .external))
  }

  func testValidateRoutingFailure() {
    let error1 = Layer.validateRouting(from: .domain, to: .presentation)
    XCTAssertNotNil(error1)
    XCTAssertTrue(error1!.contains("Invalid routing"))
    XCTAssertTrue(error1!.contains("domain cannot send messages to presentation"))

    let error2 = Layer.validateRouting(from: .external, to: .domain)
    XCTAssertNotNil(error2)
    XCTAssertTrue(error2!.contains("external cannot send messages to domain"))
  }

  // MARK: - Codable Tests

  func testCodable() throws {
    let layer = Layer.application

    // Encode
    let encoder = JSONEncoder()
    let data = try encoder.encode(layer)

    // Decode
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Layer.self, from: data)

    XCTAssertEqual(layer, decoded)
  }

  func testCodableAllLayers() throws {
    for layer in Layer.allCases {
      let encoder = JSONEncoder()
      let data = try encoder.encode(layer)

      let decoder = JSONDecoder()
      let decoded = try decoder.decode(Layer.self, from: data)

      XCTAssertEqual(layer, decoded)
    }
  }

  // MARK: - Sendable Tests

  func testSendableConformance() async {
    let layer = Layer.application

    // This should compile without warnings if Sendable is properly implemented
    await withTaskGroup(of: Layer.self) { group in
      group.addTask {
        layer
      }

      for await result in group {
        XCTAssertEqual(result, layer)
      }
    }
  }

  // MARK: - Equatable Tests

  func testEquatable() {
    XCTAssertEqual(Layer.presentation, Layer.presentation)
    XCTAssertNotEqual(Layer.presentation, Layer.application)

    for layer in Layer.allCases {
      XCTAssertEqual(layer, layer)
      for otherLayer in Layer.allCases where otherLayer != layer {
        XCTAssertNotEqual(layer, otherLayer)
      }
    }
  }
}
