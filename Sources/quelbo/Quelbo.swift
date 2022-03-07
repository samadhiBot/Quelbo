//
//  Quelbo.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/7/22.
//

import ArgumentParser
import Files
import SwiftPrettyPrint

/// Quelbo is a command line app that translates ZIL source code to Swift.
@main
struct Quelbo: ParsableCommand {
    @Argument(help: "The path to a ZIL file or a directory containing one or more ZIL files.")
    var path: String

    func run() throws {
        var game = Game()

        try gameFiles().forEach { file in
            guard file.extension?.lowercased() == "zil" else {
                return print("Skipping \(file.name)")
            }
            print("Parsing \(file.name)")
            let zil = try file.readAsString()
            try game.parse(zil)
        }

        Pretty.prettyPrint(game.tokens)
    }
}

private extension Quelbo {
    func gameFiles() throws -> [File] {
        guard let folder = try? Files.Folder(path: path) else {
            let file = try Files.File(path: path)
            return [file]
        }
        return folder.files.map { $0 }
    }
}
