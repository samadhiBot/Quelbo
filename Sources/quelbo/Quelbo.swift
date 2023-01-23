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
        help: "Print the ZIL tokens derived in the parsing phase."
    )
    var printTokens = false

    @Flag(
        name: .customShort("s"),
        help: "Print the processed game tokens when processing fails."
    )
    var printSymbolsOnFail = false

    @Flag(
        name: .customShort("u"),
        help: "Print the unprocessed game tokens when processing fails."
    )
    var printUnprocessedTokensOnFail = false

    @Option(
        name: .shortAndLong,
        help: "A target directory path to write results. If unspecified, Quelbo prints results."
    )
    var target: String?

    func run() throws {
        Game.reset()

        let game = Game.shared

        try game.parseZilSource(at: path)

        if printTokens {
            Game.Print.tokens(game.tokens)
        }

        try game.setZMachineVersion()

        try game.processTokens(
            to: target,
            printSymbolsOnFail: printSymbolsOnFail,
            printUnprocessedTokensOnFail: printUnprocessedTokensOnFail
        )
    }
}
