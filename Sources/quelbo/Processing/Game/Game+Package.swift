//
//  Game+Package.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/25/22.
//

import Files
import Foundation

extension Game {
    func package(path target: String) throws {
        guard let name = target.split(separator: "/").last else {
            throw FilesError(path: target, reason: "Unable to create package name.")
        }
        let project = "\(name)"

        let folder = try folder(path: target)
        try createPackage(named: project, in: folder)

        let sourcesFolder = try folder.subfolder(at: "Sources/\(name)")

        if !Game.directions.isEmpty {
            try createFile(
                named: "Directions.swift",
                project: project,
                in: sourcesFolder,
                with: Game.directions.codeValues()
            )
        }

        if !Game.constants.isEmpty {
            try createFile(
                named: "Constants.swift",
                project: project,
                in: sourcesFolder,
                with: Game.constants.codeValues(separator: ",")
            )
        }

        if !Game.globals.isEmpty {
            try createFile(
                named: "Globals.swift",
                project: project,
                in: sourcesFolder,
                with: Game.globals.codeValues(separator: ",")
            )
        }

        if !Game.objects.isEmpty {
            try createFile(
                named: "Objects.swift",
                project: project,
                in: sourcesFolder,
                with: Game.objects.codeValues()
            )
        }

        if !Game.rooms.isEmpty {
            try createFile(
                named: "Rooms.swift",
                project: project,
                in: sourcesFolder,
                with: Game.rooms.codeValues()
            )
        }

        if !Game.routines.isEmpty {
            try createFile(
                named: "Routines.swift",
                project: project,
                in: sourcesFolder,
                with: Game.routines.codeValues()
            )
        }
    }
}

private extension Game {
    func createFile(
        named fileName: String,
        project: String,
        in folder: Folder,
        with code: String
    ) throws {
        let file = try folder.createFile(named: fileName)
        try file.write(
            """
            //
            //  \(fileName)
            //  \(project)
            //

            import Foundation
            import Fizmo

            \(code)
            """
        )
    }

    func createPackage(named name: String, in folder: Folder) throws {
        let sources = try folder.createSubfolder(at: "Sources/\(name)")
        let tests = try folder.createSubfolder(at: "Tests/\(name)Tests")

        let readMe = try folder.createFile(named: "README.md")
        try readMe.write(
            """
            # \(name)

            A description of this package.
            """
        )

        let package = try folder.createFile(named: "Package.swift")
        try package.write(
            """
            // swift-tools-version: 5.6

            import PackageDescription

            let package = Package(
                name: "\(name)",
                dependencies: [
                    .package(url: "https://github.com/samadhiBot/Fizmo", from: "0.1.0")
                ],
                targets: [
                    .executableTarget(
                        name: "\(name)",
                        dependencies: ["Fizmo"]
                    ),
                    .testTarget(
                        name: "\(name)Tests",
                        dependencies: ["\(name)"]
                    ),
                ]
            )
            """
        )

        try createFile(
            named: "main.swift",
            project: name,
            in: sources,
            with: """
                go()
                """
        )

        try createFile(
            named: "\(name)Tests.swift",
            project: name,
            in: tests,
            with: """
                import XCTest
                import class Foundation.Bundle

                final class \(name)Tests: XCTestCase {
                    func testExample() throws {
                        // This is an example of a functional test case.
                        // Use XCTAssert and related functions to verify your tests produce the correct
                        // results.

                        // Some of the APIs that we use below are available in macOS 10.13 and above.
                        guard #available(macOS 10.13, *) else {
                            return
                        }

                        // Mac Catalyst won't have `Process`, but it is supported for executables.
                        #if !Game.targetEnvironment(macCatalyst)

                        let fooBinary = productsDirectory.appendingPathComponent("\(name)")

                        let pGame.rocess = Process()
                        process.executableURL = fooBinary

                        let pipe = Pipe()
                        process.standardOutput = pipe

                        try process.run()
                        process.waitUntilExit()

                        let data = pipe.fileHandleForReading.readDataToEndOfFile()
                        let output = String(data: data, encoding: .utf8)

                        // XCTAssertEqual(output, "Hello, world!\\n")
                        #endif
                    }

                    /// Returns path to the built products directory.
                    var productsDirectory: URL {
                      #if os(macOS)
                        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
                            return bundle.bundleURL.deletingLastPathComponent()
                        }
                        fatalError("couldn't find the products directory")
                      #else
                        return Bundle.main.bundleURL
                      #endif
                    }
                }
                """
        )
    }

    func folder(path target: String) throws -> Folder {
        var target = target
        if target.hasSuffix("/") {
            target.removeLast()
        }
        guard let existing = try? Folder(path: target) else {
            return try Folder.current.createSubfolder(at: target)
        }
        let timestamp = Date().ISO8601Format()
            .replacingOccurrences(of: ":", with: "-")
        let backupFolder = try Folder.current.createSubfolder(at: "\(target)-\(timestamp)")
        try existing.files.move(to: backupFolder)
        return existing
    }
}
