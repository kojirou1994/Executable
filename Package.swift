// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Executable",
    products: [
        .library(
            name: "Executable",
            targets: ["Executable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.1.1")
    ],
    targets: [
        .target(
            name: "Executable",
            dependencies: [
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core")
        ]),
        .testTarget(
            name: "ExecutableTests",
            dependencies: ["Executable"]),
    ]
)
