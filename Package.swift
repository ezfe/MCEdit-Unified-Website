// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "MCEditWebsite",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor-community/markdown.git", from: "0.4.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "FluentPostgreSQL", "SwiftMarkdown"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
