// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "Executable",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "ExecutableDescription", targets: ["ExecutableDescription"]),
    .library(name: "ExecutableLauncher", targets: ["ExecutableLauncher"]),
    .library(name: "FPExecutableLauncher", targets: ["FPExecutableLauncher"]),
    .library(name: "TSCExecutableLauncher", targets: ["TSCExecutableLauncher"]),
    .library(name: "PosixExecutableLauncher", targets: ["PosixExecutableLauncher"]),
    .library(name: "ExecutablePublisher", targets: ["ExecutablePublisher"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.3.0"),
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
    .package(url: "https://github.com/kojirou1994/SystemUp.git", from: "0.5.0"),
    .package(url: "https://github.com/kojirou1994/Escape.git", from: "0.0.1"),
  ],
  targets: [
    .target(
      name: "ExecutableDescription",
      dependencies: [
        .product(name: "Escape", package: "Escape"),
      ]),
    .target(
      name: "ExecutableLauncher",
      dependencies: [
        "ExecutableDescription",
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "SystemUp", package: "SystemUp"),
      ]),
    .target(
      name: "FPExecutableLauncher",
      dependencies: [
        "ExecutableLauncher",
      ]),
    .target(
      name: "TSCExecutableLauncher",
      dependencies: [
        "ExecutableLauncher",
        .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
      ]),
    .target(
      name: "PosixExecutableLauncher",
      dependencies: [
        "ExecutableLauncher",
        .product(name: "SystemFileManager", package: "SystemUp"),
        .product(name: "Command", package: "SystemUp"),
      ]),
    .target(
      name: "ExecutablePublisher",
      dependencies: [
        "FPExecutableLauncher",
      ]),
    .testTarget(
      name: "ExecutableTests",
      dependencies: ["ExecutableLauncher", "TSCExecutableLauncher", "FPExecutableLauncher"]),
  ]
)
