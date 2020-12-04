// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "MCEditWebsite",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/johnsundell/ink.git", from: "0.5.0"),
        .package(url: "https://github.com/ezfe/pwnedpasswords-provider.git", from: "2.0.3"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            "Leaf",
            "Fluent",
            "FluentPostgresDriver",
            "Redis",
            "Ink",
            "PwnedPasswords"
        ]),
        .target(name: "Run", dependencies: ["App"])
    ]
)
