//
//  Quelbo.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/7/22.
//

import ArgumentParser
import Progress

/// Quelbo is a command line app that translates ZIL source code to Swift.
@main
struct Quelbo: ParsableCommand {
    @Argument(help: "The path to a ZIL file or a directory containing one or more ZIL files.")
    var path: String

    @Flag(
        name: .short,
        help: "Whether to print the ZIL tokens derived in the parsing phase."
    )
    var printTokens = false

    @Flag(
        name: .customShort("s"),
        help: "Whether to print the processed game tokens when processing fails."
    )
    var printSymbolsOnFail = false

    @Option(
        name: .shortAndLong,
        help: "A target directory path to write results. If unspecified, Quelbo prints results."
    )
    var target: String?

    func run() throws {
        let game = Game.shared

        try game.parseZilSource(at: path)

        if printTokens {
            game.printTokens()
        }

        try game.setZMachineVersion()

        try game.processTokens(to: target, with: printSymbolsOnFail)
    }
}
