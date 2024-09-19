// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SGLocoNet",
    defaultLocalization: "en-GB",
    platforms: [.macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SGLocoNet",
            targets: ["SGLocoNet"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SGLocoNet"),
        .testTarget(
            name: "SGLocoNetTests",
            dependencies: ["SGLocoNet"]
        ),
    ]
)
