// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "adaptive_liquid_glass",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "adaptive-liquid-glass", targets: ["adaptive_liquid_glass"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "adaptive_liquid_glass",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
