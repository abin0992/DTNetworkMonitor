// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DTNetworkMonitor",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DTNetworkMonitor",
            targets: ["DTNetworkMonitor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/steipete/InterposeKit.git", from: "0.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DTNetworkMonitor",
            dependencies: ["InterposeKit"]
            ),
        .testTarget(
            name: "DTNetworkMonitorTests",
            dependencies: ["DTNetworkMonitor"]),
    ]
)
