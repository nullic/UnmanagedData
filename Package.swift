// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnmanagedData",
    platforms: [ .macOS(.v10_14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(name: "UnmanagedData", targets: ["UnmanagedData"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", .upToNextMajor(from: "0.0.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.0.0")),
        .package(url: "https://github.com/stencilproject/Stencil", .upToNextMajor(from: "0.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "UnmanagedData",
                dependencies: [.product(name: "XMLCoder", package: "XMLCoder"),
                               .product(name: "Stencil", package: "Stencil"),
                               .product(name: "ArgumentParser", package: "swift-argument-parser"),],
                resources: [
                    .copy("templates")
                ]),
    ]
)
