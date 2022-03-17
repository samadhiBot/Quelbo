// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "quelbo",
    platforms: [
        .macOS(.v12),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftPrettyPrint.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "quelbo",
            dependencies: [
                "Files",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "SwiftPrettyPrint", package: "SwiftPrettyPrint"),
            ]
        ),
        .testTarget(
            name: "quelboTests",
            dependencies: [
                "quelbo",
                .product(name: "CustomDump", package: "swift-custom-dump")
            ]
        ),
    ]
)
