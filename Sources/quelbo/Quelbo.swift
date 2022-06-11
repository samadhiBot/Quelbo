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

    @Flag(
        name: .shortAndLong,
        help: "Whether to print the ZIL tokens derived in the parsing phase."
    )
    var printTokens = false

    @Option(
        name: .shortAndLong,
        help: "A target directory path to write results. If unspecified, Quelbo prints results."
    )
    var target: String?

    func run() throws {
        let game = Game.shared
        Pretty.sharedOption = Pretty.Option(colored: true)

        try gameFiles().forEach { file in
            guard file.extension?.lowercased() == "zil" else {
                return print("Skipping \(file.name)")
            }
            print("Parsing \(file.name)")
            let zil = try file.readAsString()
            try game.parse(zil)
        }

        if printTokens {
            Pretty.prettyPrint(game.gameTokens)
        }

        try game.setZMachineVersion()

        let total: Int = game.gameTokens.count
        do {
            try game.process()

            if let target = target {
                try game.package(path: target)
            } else {
                game.printSymbols()
            }
        } catch {
            let hr = "\n========================================================================\n"
            let remaining = game.gameTokens.count
            let percentage = Int(100 * Double(total - remaining) / Double(total))
            let result = """
                Processing failed with \(remaining) of \(total) tokens unprocessed \
                (\(percentage)% complete)
                """
            print("\n⚠️  Incomplete processing results:\(hr)")
            game.printSymbols()
            print("\n⚙️  \(result)\(hr)")
            Pretty.prettyPrint(error)
            print("\n💀 \(result)\(hr)")
        }
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
