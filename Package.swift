// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "quelbo",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftPrettyPrint.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.0"),
        .package(url: "https://github.com/jkandzi/Progress.swift", from: "0.4.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.4.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.10.0"),
//        .package(url: "https://github.com/samadhiBot/Fizmo", from: "0.1.0"),
        .package(path: "/Users/sessions/Zork/Fizmo")
    ],
    targets: [
        .executableTarget(
            name: "quelbo",
            dependencies: [
                "Files",
                "Fizmo",
                "SwiftPrettyPrint",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "Progress", package: "Progress.swift"),
            ],
            swiftSettings: [
                .unsafeFlags(
                    ["-Xfrontend", "-enable-bare-slash-regex"]
                ),
                .unsafeFlags(
                    ["-Xfrontend", "-warn-long-function-bodies=100"],
                    .when(configuration: .debug)
                ),
                .unsafeFlags(
                    ["-Xfrontend", "-warn-long-expression-type-checking=100"],
                    .when(configuration: .debug)
                ),
            ]
        ),
        .testTarget(
            name: "quelboTests",
            dependencies: [
                "quelbo",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
    ]
)
