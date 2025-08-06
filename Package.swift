// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "SwiftMessageBus",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .watchOS(.v9),
    .tvOS(.v16),
  ],
  products: [
    .library(
      name: "SwiftMessageBus",
      targets: ["SwiftMessageBus"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
    .package(url: "https://github.com/google/swift-benchmark.git", from: "0.1.0"),
  ],
  targets: [
    .target(
      name: "SwiftMessageBus",
      dependencies: [
        .product(name: "Collections", package: "swift-collections")
      ]
    ),
    .target(
      name: "SwiftMessageBusMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "SwiftMessageBusClient",
      dependencies: ["SwiftMessageBusMacros"]
    ),
    .testTarget(
      name: "SwiftMessageBusTests",
      dependencies: ["SwiftMessageBus"]
    ),
    .executableTarget(
      name: "MessageBusBenchmarks",
      dependencies: [
        "SwiftMessageBus",
        .product(name: "Benchmark", package: "swift-benchmark"),
      ],
      path: "Benchmarks/MessageBusBenchmarks"
    ),
  ]
)
