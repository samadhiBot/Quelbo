//
//  Game+Processor.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import CustomDump
import Foundation
import Progress
import os.log
import SwiftPrettyPrint

extension Game {
    class Processor {
        /// An array of any errors encountered during game processing.
        private(set) var errors: [String] = []

        /// <#Description#>
        let printSymbolsOnFail: Bool

        /// <#Description#>
        private(set) var progressBar: ProgressBar

        /// <#Description#>
        let target: String?

        /// <#Description#>
        private(set) var tokens: [Token]

        /// <#Description#>
        let initialTokenCount: Int

        init(
            tokens: [Token],
            target: String?,
            printSymbolsOnFail: Bool
        ) {
            self.printSymbolsOnFail = printSymbolsOnFail
            self.target = target
            self.tokens = tokens
            self.initialTokenCount = tokens.count
            self.progressBar = ProgressBar(
                count: tokens.count,
                configuration: [
                    ProgressBarLine(barLength: 65),
                    ProgressPercent(),
                ]
            )
        }

        func processTokens() throws {
            Game.Print.heading("􀥏 Processing Zil Tokens")

            do {
                try process()

                if let target = target {
                    try Game.Package(path: target).build()
                } else {
                    Game.Print.symbols()
                }
            } catch {
                if printSymbolsOnFail {
                    Game.Print.heading("\n􀦆 Successfully processed symbols:")
                    Game.Print.symbols()
                }

                let percentage = Int(
                    100 * Double(initialTokenCount - tokens.count) / Double(initialTokenCount)
                )
                let result = """

                    􀘰 Processing failed with \(tokens.count) of \(initialTokenCount) tokens unprocessed \
                    (\(percentage)% complete)
                    """

                Game.Print.heading(result)

                Pretty.prettyPrint(error)

                print("\(result)\n")
            }
        }
    }
}

extension Game.Processor {
    private func process() throws {
        let total = initialTokenCount

        while !tokens.isEmpty {
            let remaining = tokens.count

            Logger.process.info("􀣋 Processing tokens: \(remaining) of \(total) remaining")
            progressBar.setValue(initialTokenCount - remaining)

            try processZilTokens()

            if tokens.count == remaining {
                throw GameError.failedToProcessTokens(
                    errors.sorted().unique
                )
            }
        }

        Logger.process.info("􀦆 Processing complete!")
    }

    private func processZilTokens() throws {
        var errors: [String] = []
        var unprocessedTokens: [Token] = []

        tokens.forEach { token in
            switch token {
            case .atom, .bool, .character, .decimal, .eval, .global, .list,
                 .local, .property, .quote, .segment, .type, .vector, .verb:
                Logger.process.warning("􀁜 Unexpected: \(token.value, privacy: .public)")

            case .commented, .string:
                Logger.process.info("􀌤 Comment: \(token.value, privacy: .public)")

            case .form(let formTokens):
                do {
                    var tokens = formTokens
                    var localVariables: [Variable] = []

                    guard case .atom(let zilString) = tokens.shift() else {
                        throw GameError.unknownDirective(tokens)
                    }

                    Logger.process.debug(
                        "􀊫 \(zilString, privacy: .public) \(tokens[0].value, privacy: .public)"
                    )

                    let factory = try Game.makeFactory(
                        zil: zilString,
                        tokens: tokens,
                        with: &localVariables,
                        type: .mdl
                    )

                    Logger.process.debug(
                        "   􀎕 Factory: \(String(describing: factory), privacy: .public)"
                    )

                    let symbol = try factory.process()
                    try Game.commit(symbol)

                    Logger.process.info("   􀋃 Processed: \(symbol.debugDescription, privacy: .public)")

                    progressBar.next()

                } catch {
                    var description = ""
                    customDump(error, to: &description)

                    Logger.process.warning("   􀇿 \(description, privacy: .public)")

                    errors.append("\(description)")

                    unprocessedTokens.append(token)
                }
            }
        }
        self.errors = errors
        self.tokens = unprocessedTokens
    }
}
