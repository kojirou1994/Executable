// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Executable",
    products: [
        .library(
            name: "Executable",
            targets: ["Executable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "Executable",
            dependencies: ["SwiftToolsSupport-auto"]),
        .testTarget(
            name: "ExecutableTests",
            dependencies: ["Executable"]),
    ]
)
