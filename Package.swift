// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "quelbo",
    platforms: [
        .macOS(.v12),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftPrettyPrint", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.0"),
        .package(url: "https://github.com/jkandzi/Progress.swift", from: "0.4.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.4.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.9.0"),
//        .package(url: "https://github.com/samadhiBot/Fizmo", branch: "table"),
        .package(path: "/Users/sessions/Zork/Fizmo")
    ],
    targets: [
        .executableTarget(
            name: "quelbo",
            dependencies: [
                "Files",
                "Fizmo",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "Progress", package: "Progress.swift"),
                .product(name: "SwiftPrettyPrint", package: "SwiftPrettyPrint"),
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
