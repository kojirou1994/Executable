// swift-tools-version: 6.0

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
    .library(name: "PosixExecutableLauncher", targets: ["PosixExecutableLauncher"]),
    .library(name: "ExecutablePublisher", targets: ["ExecutablePublisher"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
    .package(url: "https://github.com/kojirou1994/SystemUp.git", branch: "main"),
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
      dependencies: ["ExecutableLauncher", "PosixExecutableLauncher", "FPExecutableLauncher"]),
  ]
)
