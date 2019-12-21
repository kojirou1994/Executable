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
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .revision("edc19d30a674cb9f3311b77ffb406dc7c5d2f540"))
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
