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
                    with: Game.directions.sorted.codeValues(),
                    wrapper: """
                        /// Custom directions defined in \(project).
                        extension Direction {
                            {{code}}
                        }
                        """
                )
            }

            if !Game.constants.isEmpty {
                try createFile(
                    named: "Constants.swift",
                    project: project,
                    in: sourcesFolder,
                    with: Game.constants.sorted.codeValues(.doubleLineBreak),
                    wrapper: """
                        /// Immutable constants defined in \(project).
                        struct Constants {
                            {{code}}
                        }
                        """
                )
            }

            if !Game.globals.isEmpty {
                try createFile(
                    named: "Globals.swift",
                    project: project,
                    in: sourcesFolder,
                    with: Game.globals.sorted.codeValues(.doubleLineBreak),
                    wrapper: """
                        /// Mutable global values defined in \(project).
                        class Globals: Codable {
                            {{code}}
                        }
                        """
                )
            }

            if !Game.objects.isEmpty {
                try createFile(
                    named: "Objects.swift",
                    project: project,
                    in: sourcesFolder,
                    with: Game.objects.sorted.codeValues(.doubleLineBreak),
                    wrapper: """
                        /// Mutable objects defined in \(project).
                        class Objects: Codable {
                            {{code}}
                        }
                        """
                )
            }

            if !Game.rooms.isEmpty {
                try createFile(
                    named: "Rooms.swift",
                    project: project,
                    in: sourcesFolder,
                    with: """
                        /// Mutable rooms defined in \(project).
                        class Rooms: Codable {
                        \(Game.rooms.sorted.codeValues(.doubleLineBreak).indented)
                        }

                        // MARK: - Shortcuts

                        extension Rooms {
                            static var Global: Globals { \(project).shared.globals }
                            static var Object: Objects { \(project).shared.objects }
                        }
                        """
                )
            }

            if !Game.routines.isEmpty {
                let routines = Game.routines.sorted
                let mappings = routines.compactMap { routine in
                    guard let id = routine.id else { return nil }
                    return """
                        "\(id)": .voidVoid(\(id)),
                        """
                }.joined(separator: "\n            ")

                try createFile(
                    named: "Actions.swift",
                    project: project,
                    in: sourcesFolder,
                    with: routines.codeValues(.doubleLineBreak),
                    wrapper: """
                        /// \(project) action mappings.
                        extension \(project) {
                            var actions: [Routine.ID: Routine.Function] {
                                [
                                    \(mappings)
                                ]
                            }
                        }

                        // MARK: - Action definitions

                        /// \(project) action definitions.
                        extension \(project) {
                            {{code}}
                        }
                        """
                )
            }

            if !Game.syntax.isEmpty {
                try createFile(
                    named: "Syntax.swift",
                    project: project,
                    in: sourcesFolder,
                    with: Game.syntax.sorted.codeValues(.commaLineBreakSeparated),
                    wrapper: """
                        /// Syntax rules defined in \(project).
                        extension Syntax {
                            static private(set) var rules: [Syntax] = [
                            {{code}}
                            ]
                        }
                        """
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
        with code: String,
        wrapper: String? = nil
    ) throws {
        let file = try folder.createFile(named: fileName)
        var wrappedCode: String {
            guard let wrapper else { return code }
            return wrapper
                .replacingOccurrences(of: "        {{code}}", with: code.indented.indented)
                .replacingOccurrences(of: "    {{code}}", with: code.indented)
        }
        try file.write(
            """
            //
            //  \(fileName)
            //  \(project)
            //
            //  Translated from ZIL to Swift by Quelbo on \(today).
            //

            import Fizmo

            \(wrappedCode)
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

        var plusCustomDirections: String {
            let directions = Game.directions
            guard !directions.isEmpty else { return "" }
            return "+ [\(directions.sorted.handles(.dotPrefixed))]"
        }

        try createFile(
            named: "main.swift",
            project: name,
            in: sources,
            with: """
                /// Represents the \(project) game.
                final class \(project) {
                    let constants: Constants
                    let directions: [Direction]
                    let globals: Globals
                    let objects: Objects
                    let rooms: Rooms

                    private init() {
                        constants = Constants()
                        directions = Direction.defaults\(plusCustomDirections)
                        globals = Globals()
                        objects = Objects()
                        rooms = Rooms()
                    }

                    private(set) static var shared = \(project)()
                }

                \(project).shared.go()
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

    private var today: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: Date())
    }
}
