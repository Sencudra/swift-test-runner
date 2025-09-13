// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "TestEnvironment",
    products: [
        .library(
            name: "TestEnvironment",
            targets: ["TestEnvironment"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3")
    ],
    targets: [
        .target(
            name: "TestEnvironment",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics")
            ]
        ),
        .testTarget(
            name: "TestEnvironmentTests",
            dependencies: [
                "TestEnvironment",
                .product(name: "Numerics", package: "swift-numerics")
            ]
        )
    ]
)
