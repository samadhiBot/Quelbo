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
                    try Game.Package(path: target).build()
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
                "􀣋 Processing tokens: \(remaining) of \(total) remaining (iteration \(iteration))"
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

        Game.Print.heading("􀦆 Processing complete!")
    }

    private func processZilTokens() throws {
        var errors: [String] = []
        var unprocessedTokens: [Token] = []

        tokens.forEach { token in
            switch token {
            case .atom, .bool, .character, .decimal, .eval, .global, .list, .local, 
                 .property, .quote, .segment, .type, .vector, .verb, .word:
                Logger.process.warning("􀁜 Unexpected: \(token.value, privacy: .public)")

            case .commented, .string:
                Logger.process.info("􀌤 Comment: \(token.value, privacy: .public)")

            case .form(let formTokens):
                do {
                    var tokens = formTokens
                    var localVariables: [Statement] = []

                    guard case .atom(let zilString) = tokens.shift() else {
                        throw GameError.unknownDirective(tokens)
                    }

                    Logger.process.info(
                        "􀊫 \(zilString, privacy: .public) \(tokens.first?.value ?? "", privacy: .public)"
                    )

                    let symbol = try Game.process(
                        zil: zilString,
                        tokens: tokens,
                        with: &localVariables,
                        type: .mdl
                    )
                    try Game.commit(symbol)

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

// MARK: - Game.process

extension Game {
    static func process(
        zil: String,
        tokens: [Token],
        with localVariables: inout [Statement],
        type factoryType: Factories.FactoryType? = nil,
        mode factoryMode: Factory.FactoryMode = .process
    ) throws -> Symbol {
        if let factory = Game.findFactory(zil, type: factoryType) {
            let factoryTokens: [Token] = {
                switch tokens.first {
                case .atom(zil): return tokens.droppingFirst
                case .decimal: return tokens.droppingFirst
                case .global(.atom(zil)): return tokens.droppingFirst
                default: return tokens
                }
            }()
            return try factory.init(
                factoryTokens,
                with: &localVariables,
                mode: factoryMode
            ).processOrEvaluate()
        }

        if Game.routines.find(zil.lowerCamelCase) != nil {
            return try Factories.RoutineCall(
                tokens,
                with: &localVariables,
                mode: factoryMode
            ).processOrEvaluate()
        }

        if Game.findDefinition(zil.lowerCamelCase) != nil {
            let routine = try Factories.DefinitionEvaluate(
                tokens,
                with: &localVariables,
                mode: factoryMode
            ).processOrEvaluate()

            try Game.commit(routine)

            return try Factories.RoutineCall(
                tokens,
                with: &localVariables,
                mode: factoryMode
            ).processOrEvaluate()
        }

        return .definition(
            id: "%\(zil.lowerCamelCase)-\(UUID().uuidString)",
            tokens: tokens,
            localVariables: localVariables
        )
    }
}
