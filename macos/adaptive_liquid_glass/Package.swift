// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "adaptive_liquid_glass",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "adaptive-platform-ui", targets: ["adaptive_liquid_glass"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "adaptive_liquid_glass",
            dependencies: []
        )
    ]
)

