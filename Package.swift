// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "MCEditWebsite",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.3.1"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.2"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.4.0"),
        .package(url: "https://github.com/johnsundell/ink.git", from: "0.1.1"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.4"),
        .package(url: "https://github.com/ezfe/pwnedpasswords-provider.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "FluentPostgreSQL", "Redis", "Ink", "Authentication", "PwnedPasswords"]),
        .target(name: "Run", dependencies: ["App"])
    ]
)
