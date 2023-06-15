// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSSEStream",
    platforms: [.iOS(.v13), .macOS(.v10_15), .macCatalyst(.v13), .watchOS(.v6), .tvOS(.v13)],
    products: [
        .library(
            name: "SwiftSSEStream",
            targets: ["SwiftSSEStream"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftSSEStream",
            dependencies: []
        )
    ]
)
