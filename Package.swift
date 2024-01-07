// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Network-iOS",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "Network-iOS",
      targets: ["Network-iOS"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Moya/Moya.git", exact: "15.0.3")
  ],
  targets: [
    .target(
      name: "Network-iOS",
      dependencies: [
        .product(name: "CombineMoya", package: "Moya")
      ]),
    .testTarget(
      name: "Network-iosTests",
      dependencies: ["Network-iOS"]),
  ]
)
