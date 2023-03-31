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
    /// A structure representing a Swift package containing the game translation.
    struct Package {
        private let project: String
        private var folder: Folder = .current
        private var sourcesFolder: Folder = .current

        /// Initializes a new `Package` with the provided target path.
        ///
        /// - Parameter target: The target file path for the package.
        ///
        /// - Throws: An error if unable to create a package name.
        init(path target: String) throws {
            guard let name = target.split(separator: "/").last else {
                throw FilesError(path: target, reason: "Unable to create package name.")
            }
            self.project = "\(name.capitalized)"

            self.folder = try folder(path: "Output/\(target)")
            try createPackage(named: project, in: folder)

            self.sourcesFolder = try folder.subfolder(at: "Sources/\(name)")
        }

        /// Builds the package by adding various game components.
        ///
        /// - Throws: An error if unable to add game components to the package.
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
    /// Adds the action mappings to the package.
    ///
    /// - Throws: An error if unable to add actions.
    func addActions() throws {
        guard !Game.actions.isEmpty else { return }

        let mappings = Game.routines.sorted.compactMap { routine in
            guard let id = routine.id else { return nil }
            return """
                "\(id)": .\(routine.signature)(\(id)),
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

    /// Adds constants to the package.
    ///
    /// - Throws: An error if unable to add constants.
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

    /// Adds directions to the package.
    ///
    /// - Throws: An error if unable to add directions.
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

    /// Adds global values to the package.
    ///
    /// - Throws: An error if unable to add globals.
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

    /// Adds objects to the package.
    ///
    /// - Throws: An error if unable to add objects.
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

    /// Adds rooms to the package.
    ///
    /// - Throws: An error if unable to add rooms.
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

    /// Adds routines to the package.
    ///
    /// - Throws: An error if unable to add routines.
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

    /// Adds syntax rules to the package.
    ///
    /// - Throws: An error if unable to add syntax.
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
    /// Creates a file with the provided information.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file to create.
    ///   - project: The name of the project.
    ///   - folder: The folder in which to create the file.
    ///   - code: The code to write in the file.
    ///   - wrapper: An optional wrapper string for the code.
    ///
    /// - Throws: An error if unable to create or write to the file.
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

    /// Creates a package with the provided name in the specified folder.
    ///
    /// - Parameters:
    ///   - name: The name of the package.
    ///   - folder: The folder in which to create the package.
    ///
    /// - Throws: An error if unable to create the package.
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

    /// Returns a folder for the specified path.
    ///
    /// - Parameter target: The target path for the folder.
    ///
    /// - Throws: An error if unable to create or find the folder.
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

    /// Returns a string representation of the current date.
    private var today: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: Date())
    }
}
