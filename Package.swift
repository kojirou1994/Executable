// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "Executable",
  platforms: [
    .macOS(.v10_13)
  ],
  products: [
    .library(
      name: "Executable",
      targets: ["ExecutableLauncher"]),
    .library(
      name: "ExecutableDescription",
      targets: ["ExecutableDescription"]),
    .library(
      name: "ExecutableLauncher",
      targets: ["ExecutableLauncher"]),
    .library(
      name: "ExecutablePublisher",
      targets: ["ExecutablePublisher"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.1.1")
  ],
  targets: [
    .target(
      name: "ExecutableDescription"),
    .target(
      name: "ExecutableLauncher",
      dependencies: [
        "ExecutableDescription",
        .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core")
      ]),
    .target(
      name: "ExecutablePublisher",
      dependencies: [
        "ExecutableLauncher"
      ]),
    .testTarget(
      name: "ExecutableTests",
      dependencies: ["ExecutableLauncher"]),
  ]
)
