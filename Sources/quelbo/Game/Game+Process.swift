//
//  Game+Process.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import CustomDump
import Foundation
import Progress

extension Game {
    func processTokens(
        to target: String? = nil,
        with printSymbolsOnFail: Bool = false
    ) throws {
        let total: Int = gameTokens.count
        var progressBar = ProgressBar(
            count: total,
            configuration: [
                ProgressBarLine(barLength: 65),
                ProgressPercent(),
            ]
        )

        printHeading("⚙️  Processing Zil Tokens")
        do {
            try process(
                bar: &progressBar,
                total: total,
                remaining: total
            )

            if let target = target {
                try package(path: target)
            } else {
                printSymbols()
            }
        } catch {
            if printSymbolsOnFail {
                printHeading("\n🥈  Successfully processed symbols:")
                printSymbols()
            }

            let percentage = Int(100 * Double(total - gameTokens.count) / Double(total))
            let result = """

                💀 Processing failed with \(gameTokens.count) of \(total) tokens unprocessed \
                (\(percentage)% complete)
                """
            printHeading(result)
            customDump(error)
            print("\(result)\n")
        }
    }
}

extension Game {
    func process(
        bar progressBar: inout ProgressBar,
        total: Int,
        remaining: Int
    ) throws {
        try processZilTokens()
        progressBar.setValue(total - gameTokens.count)

        if gameTokens.isEmpty {
            return print("\nProcessing complete!\n")
        }
        if gameTokens.count == remaining {
            throw GameError.failedToProcessTokens(
                processingErrors.sorted().unique
            )
        }
        try process(
            bar: &progressBar,
            total: total,
            remaining: gameTokens.count
        )
    }

    func processZilTokens() throws {
        var unprocessedTokens: [Token] = []
        processingErrors = []

        try gameTokens.forEach { token in
            switch token {
            case .bool, .character, .decimal, .global, .list, .local, .quote, .vector:
                throw GameError.unexpectedAtRootLevel(token)
            case .form(let formTokens):
                do {
                    var tokens = formTokens
                    var registry: [Symbol] = []
                    guard case .atom(let zil) = tokens.shift() else {
                        throw GameError.unknownDirective(tokens)
                    }
                    let factory: SymbolFactory
                    if let zilSymbol = try Game.zilSymbolFactories
                        .find(zil)?
                        .init(tokens, with: &registry)
                    {
                        factory = zilSymbol
                    } else {
                        factory = try Factories.RoutineCall(formTokens, with: &registry)
                    }
                    _ = try factory.process()
                } catch {
                    processingErrors.append("\(error)")
                    unprocessedTokens.append(token)
                }
            default:
                break // ignored
            }
        }
        self.gameTokens = unprocessedTokens
    }

    func setZMachineVersion() throws {
        for token in gameTokens {
            guard
                case .form(var formTokens) = token,
                case .atom("VERSION") = formTokens.shift()
            else {
                continue
            }
            self.zMachineVersion = try Game.ZMachineVersion(tokens: formTokens)
            break
        }

        printHeading(
            """

            💾 Z-machine version
            """,
            zMachineVersion.rawValue
        )
    }
}
