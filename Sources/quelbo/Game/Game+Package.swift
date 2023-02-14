//
//  Game+Package.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/25/22.
//

import Files
import Foundation
import os.log

extension Game {
    struct Package {
        private let project: String
        private var folder: Folder = .current
        private var sourcesFolder: Folder = .current

        init(path target: String) throws {
            guard let name = target.split(separator: "/").last else {
                throw FilesError(path: target, reason: "Unable to create package name.")
            }
            self.project = "\(name)"

            self.folder = try folder(path: "Output/\(target)")
            try createPackage(named: project, in: folder)

            self.sourcesFolder = try folder.subfolder(at: "Sources/\(name)")
        }

        func build() throws {
            if !Game.directions.isEmpty {
                try createFile(
                    named: "Directions.swift",
                    project: project,
                    in: sourcesFolder,
                    with: Game.directions.sorted.codeValues()
                )
            }

            if !Game.constants.isEmpty {
                try createFile(
                    named: "Constants.swift",
                    project: project,
                    in: sourcesFolder,
                    with: Game.constants.sorted.codeValues(.doubleLineBreak)
                )
            }

            if !Game.globals.isEmpty {
                try createFile(
                    named: "Globals.swift",
                    project: project,
                    in: sourcesFolder,
                    with: Game.globals.sorted.codeValues(.doubleLineBreak)
                )
            }

            if !Game.objects.isEmpty {
                try createFile(
                    named: "Objects.swift",
                    project: project,
                    in: sourcesFolder,
                    with: Game.objects.sorted.codeValues(.doubleLineBreak)
                )
            }

            if !Game.rooms.isEmpty {
                try createFile(
                    named: "Rooms.swift",
                    project: project,
                    in: sourcesFolder,
                    with: Game.rooms.sorted.codeValues(.doubleLineBreak)
                )
            }

            if !Game.routines.isEmpty {
                try createFile(
                    named: "Routines.swift",
                    project: project,
                    in: sourcesFolder,
                    with: Game.routines.sorted.codeValues(.doubleLineBreak)
                )
            }

            if !Game.syntax.isEmpty {
                try createFile(
                    named: "Syntax.swift",
                    project: project,
                    in: sourcesFolder,
                    with: Game.syntax.sorted.codeValues(.doubleLineBreak)
                )
            }
        }
    }
}

private extension Game.Package {
    private func createFile(
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

    private func createPackage(named name: String, in folder: Folder) throws {
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
            // swift-tools-version: 5.7

            import PackageDescription

            let package = Package(
                name: "\(name)",
                dependencies: [
                    // .package(url: "https://github.com/samadhiBot/Fizmo", branch: "main")
                    .package(path: "/Users/sessions/Zork/Fizmo")
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

                final class \(name)Tests: XCTestCase {
                    func testExample() throws {

                    }
                }
                """
        )

        Logger.package.info(
            "\t􀁢 Created package \(name, privacy: .public) in \(folder, privacy: .public)"
        )
    }

    private func folder(path target: String) throws -> Folder {
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
