// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KeyStatsCoreTests",
    products: [
        .library(name: "KeyStatsCore", targets: ["KeyStatsCore"])
    ],
    targets: [
        .target(
            name: "KeyStatsCore",
            path: "Sources/KeyStatsCore"
        ),
        .testTarget(
            name: "KeyStatsCoreTests",
            dependencies: ["KeyStatsCore"],
            path: "KeyStatsTests",
            sources: ["AppStatsTests.swift"]
        )
    ]
)
