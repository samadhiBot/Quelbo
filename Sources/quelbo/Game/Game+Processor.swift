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
        let printUnprocessedTokensOnFail: Bool

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
            printSymbolsOnFail: Bool,
            printUnprocessedTokensOnFail: Bool
        ) {
            self.printSymbolsOnFail = printSymbolsOnFail
            self.printUnprocessedTokensOnFail = printUnprocessedTokensOnFail
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
            Game.Print.heading("􀥏  Processing Zil Tokens")

            do {
                try process()

                if let target {
                    Game.Print.heading("􀪏  Writing game translation to ./Output/\(target)")
                    try Game.Package(path: target).build()
                    print("Done!\n")
                } else {
                    Game.Print.symbols()
                }

            } catch {
                if printSymbolsOnFail {
                    Game.Print.heading("\n􀦆  Successfully processed symbols:")
                    Game.Print.symbols()
                }

                if printUnprocessedTokensOnFail {
                    Game.Print.heading(
                        "􀱏  Unprocessed tokens:",
                        tokens.map(\.zil).sorted().values(.doubleLineBreak)
                    )
                }

                let percentage = Int(
                    100 * Double(initialTokenCount - tokens.count) / Double(initialTokenCount)
                )
                let result = """

                    􀘰  Processing failed with \(tokens.count) of \(initialTokenCount) tokens \
                    unprocessed (\(percentage)% complete) with \(errors.count) errors
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
        var iteration = 0

        while !tokens.isEmpty {
            let remaining = tokens.count
            iteration += 1

            Game.Print.heading(
                "􀣋  Processing tokens: \(remaining) of \(total) remaining (iteration \(iteration))"
            )
            progressBar.setValue(initialTokenCount - remaining)

            try processZilTokens()

            if tokens.count == remaining {
                throw GameError.failedToProcessTokens(
                    errors.sorted().unique
                )
            }

            print("")
        }

        Game.Print.heading("􀦆  Processing complete!")
    }

    private func processZilTokens() throws {
        var errors: [String] = []
        var unprocessedTokens: [Token] = []

        tokens.forEach { token in
            switch token {
            case .action, .atom, .bool, .character, .decimal, .global, .list, .local,
                    .partsOfSpeech, .partsOfSpeechFirst, .property, .quote, .segment, .type,
                    .vector, .verb, .word:
                Logger.process.warning("􀁜 Unexpected: \(token, privacy: .public)")

            case .commented, .string:
                Logger.process.info("􀌤 Comment: \(token.value, privacy: .public)")

            case .eval(let evalToken):
                do {
                    var localVariables: [Statement] = []

                    guard
                        case .form(let evalFormTokens) = evalToken,
                        case .atom(let zilString) = evalFormTokens.first
                    else {
                        throw GameError.unknownRootEvaluation(token)
                    }

                    Logger.process.info(
                        """
                        􁇥 \(zilString, privacy: .public) \
                        \(evalFormTokens.first?.value ?? "", privacy: .public)
                        """
                    )

                    let symbol = try Game.Element(
                        zil: zilString,
                        tokens: evalFormTokens,
                        with: &localVariables,
                        type: .mdl,
                        mode: .evaluate
                    ).process()

                    Logger.process.info(
                        "\t􀋃 Processed: \(symbol.debugDescription, privacy: .public)"
                    )

                    progressBar.next()

                } catch {
                    var description = ""
                    customDump(error, to: &description)

                    Logger.process.warning("\t􀇿 \(description, privacy: .public)")

                    errors.append("\(description)")

                    unprocessedTokens.append(token)
                }

            case .form(let formTokens):
                do {
                    var tokens = formTokens
                    var localVariables: [Statement] = []

                    guard case .atom(let zilString) = tokens.shift() else {
                        throw GameError.unknownDirective(tokens)
                    }

                    Logger.process.info(
                        """
                        􀊫 \(zilString, privacy: .public) \
                        \(tokens.first?.value ?? "", privacy: .public)
                        """
                    )

                    let symbol = try Game.Element(
                        zil: zilString,
                        tokens: tokens,
                        with: &localVariables,
                        type: .mdl
                    ).process()

                    Logger.process.info(
                        "\t􀋃 Processed: \(symbol.debugDescription, privacy: .public)"
                    )

                    progressBar.next()

                } catch {
                    var description = ""
                    customDump(error, to: &description)

                    Logger.process.warning("\t􀇿 \(description, privacy: .public)")

                    errors.append("\(description)")

                    unprocessedTokens.append(token)
                }
            }
        }
        self.errors = errors
        self.tokens = unprocessedTokens
    }
}
