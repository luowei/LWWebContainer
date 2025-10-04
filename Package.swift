// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LWWebContainer",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "LWWebContainer",
            targets: ["LWWebContainer"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LWWebContainer",
            dependencies: [],
            path: "LWWebContainer/Swift",
            exclude: ["LWWebContainerUsageExamples.swift"],
            resources: [
                .process("../Assets")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
