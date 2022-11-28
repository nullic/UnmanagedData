// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnmanagedData",
    products: [
        .executable(name: "umd", targets: ["UnmanagedData"]),
        .plugin(name: "UnmanagedDataPlugin", targets: ["UnmanagedDataPlugin"]),
        .plugin(name: "UnmanagedDataPlugin-Generate", targets: ["UnmanagedDataPlugin-Generate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/XMLCoder", from: "0.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.0.0"),
        .package(url: "https://github.com/tattn/MoreCodable.git", from: "0.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
    ],
    targets: [
        .executableTarget(name: "UnmanagedData", dependencies: [
            .product(name: "XMLCoder", package: "XMLCoder"),
            .product(name: "StencilSwiftKit", package: "StencilSwiftKit"),
            .product(name: "MoreCodable", package: "MoreCodable"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "Yams", package: "Yams"),
            .product(name: "PathKit", package: "PathKit"),
        ]),
        
        .plugin(name: "UnmanagedDataPlugin",
                capability: .buildTool(),
                dependencies: ["UnmanagedData"]),

        .plugin(name: "UnmanagedDataPlugin-Generate",
                capability: .command(
                    intent: .custom(
                        verb: "generate-code-from-core-data-model",
                        description: "Creates source code from Core Data model"
                    ),
                    permissions: [
                        .writeToPackageDirectory(reason: "This command generates source code")
                    ]
                ),
                dependencies: ["UnmanagedData"]),
    ]
)
