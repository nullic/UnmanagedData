// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnmanagedData",
    platforms: [.macOS(.v10_14)],
    products: [
        .executable(name: "umd", targets: ["UnmanagedData"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/XMLCoder", from: "0.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.0.0"),
        .package(url: "https://github.com/tattn/MoreCodable.git", from: "0.0.0"),
    ],
    targets: [
        .target(name: "UnmanagedData", dependencies: [
            .product(name: "XMLCoder", package: "XMLCoder"),
            .product(name: "StencilSwiftKit", package: "StencilSwiftKit"),
            .product(name: "MoreCodable", package: "MoreCodable"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
    ]
)
