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
            self.project = "\(name.capitalized)"

            self.folder = try folder(path: "Output/\(target)")
            try createPackage(named: project, in: folder)

            self.sourcesFolder = try folder.subfolder(at: "Sources/\(name)")
        }

        func build() throws {
            try addActions()
            try addConstants()
            try addDirections()
            try addGlobals()
            try addObjects()
            try addRooms()
            try addRoutines()
            try addSyntax()
        }
    }
}

private extension Game.Package {
    func addActions() throws {
        guard !Game.routines.isEmpty else { return }

        let mappings = Game.routines.sorted.compactMap { routine in
            guard let id = routine.id else { return nil }
            return """
                "\(id)": .voidVoid(\(id)),
                """
        }.joined(separator: "\n")

        try createFile(
            named: "Actions.swift",
            project: project,
            in: sourcesFolder,
            with: mappings,
            wrapper: """
                /// \(project) action mappings.
                extension \(project) {
                    var actions: [Routine.ID: Routine.Function] {
                        [
                            {{code}}
                        ]
                    }
                }
                """
        )
    }

    func addConstants() throws {
        guard !Game.constants.isEmpty else { return }

        try createFile(
            named: "Constants.swift",
            project: project,
            in: sourcesFolder,
            with: Game.constants.sorted.codeValues(.doubleLineBreak),
            wrapper: """
                /// Immutable constants defined in \(project).
                struct \(project)Constants {
                    {{code}}
                }
                """
        )
    }

    func addDirections() throws {
        guard !Game.directions.isEmpty else { return }

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


    func addGlobals() throws {
        guard !Game.globals.isEmpty else { return }

        try createFile(
            named: "Globals.swift",
            project: project,
            in: sourcesFolder,
            with: Game.globals.sorted.codeValues(.doubleLineBreak),
            wrapper: """
                /// Mutable global values defined in \(project).
                class \(project)Globals: Codable {
                    {{code}}
                }
                """
        )
    }

    func addObjects() throws {
        guard !Game.objects.isEmpty else { return }

        try createFile(
            named: "Objects.swift",
            project: project,
            in: sourcesFolder,
            with: Game.objects.sorted.codeValues(.doubleLineBreak),
            wrapper: """
                /// Mutable objects defined in \(project).
                class \(project)Objects: Codable {
                    {{code}}
                }
                """
        )
    }

    func addRooms() throws {
        guard !Game.rooms.isEmpty else { return }

        try createFile(
            named: "Rooms.swift",
            project: project,
            in: sourcesFolder,
            with: Game.rooms.sorted.codeValues(.doubleLineBreak).indented,
            wrapper: """
                /// Mutable rooms defined in \(project).
                class \(project)Rooms: Codable {
                    {{code}}
                }
                """
        )
    }

    func addRoutines() throws {
        guard !Game.routines.isEmpty else { return }

        try createFile(
            named: "Routines.swift",
            project: project,
            in: sourcesFolder,
            with: Game.routines.sorted.codeValues(.doubleLineBreak),
            wrapper: """
                /// \(project) action definitions.
                extension \(project) {
                    {{code}}
                }
                """
        )
    }

    func addSyntax() throws {
        guard !Game.syntax.isEmpty else { return }

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
                .replacingOccurrences(of: "            {{code}}", with: code.indented.indented.indented)
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

        var directions: String {
            (Game.directions.first?.payload?.symbols ?? [])
                .compactMap {
                    guard let id = $0.id else { return nil }
                    return ".\(id),"
                }
                .joined(separator: "\n            ")
        }

        try createFile(
            named: "main.swift",
            project: name,
            in: sources,
            with: """
                /// Represents the \(project) game.
                final class \(project) {
                    let constants: \(project)Constants
                    let directions: [Direction]
                    let globals: \(project)Globals
                    let objects: \(project)Objects
                    let rooms: \(project)Rooms

                    private init() {
                        constants = \(project)Constants()
                        directions = [
                            \(directions)
                        ]
                        globals = \(project)Globals()
                        objects = \(project)Objects()
                        rooms = \(project)Rooms()
                    }

                    private(set) static var shared = \(project)()
                }

                /// A global shortcut to the \(project) game constants.
                var Constants: \(project)Constants {
                    \(project).shared.constants
                }

                /// A global shortcut to the \(project) game globals.
                var Globals: \(project)Globals {
                    \(project).shared.globals
                }

                /// A global shortcut to the \(project) game objects.
                var Objects: \(project)Objects {
                    \(project).shared.objects
                }

                /// A global shortcut to the \(project) game rooms.
                var Rooms: \(project)Rooms {
                    \(project).shared.rooms
                }

                try \(project).shared.go()
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
