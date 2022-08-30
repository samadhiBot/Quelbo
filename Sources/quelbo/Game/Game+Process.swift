//
//  Game+Process.swift
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
    func processTokens(
        to target: String? = nil,
        with printSymbolsOnFail: Bool = false
    ) throws {
        let total: Int = tokens.count
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

            let percentage = Int(100 * Double(total - tokens.count) / Double(total))
            let result = """

                💀 Processing failed with \(tokens.count) of \(total) tokens unprocessed \
                (\(percentage)% complete)
                """

            printHeading(result)

            Pretty.prettyPrint(error)

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
        Logger.process.info("Processing tokens: \(remaining) of \(total) remaining")

        try processZilTokens(bar: &progressBar)

        if tokens.isEmpty {
            return print("\n🏆 Processing complete!\n")
        }

        if tokens.count == remaining {
            throw GameError.failedToProcessTokens(
                errors.sorted().unique
            )
        }

        try process(
            bar: &progressBar,
            total: total,
            remaining: tokens.count
        )
    }

    func processZilTokens(bar progressBar: inout ProgressBar) throws {
        var unprocessedTokens: [Token] = []
        errors = []

        try tokens.forEach { token in
            switch token {
            case .bool, .character, .decimal, .global, .list, .local, .quote, .vector:
                throw GameError.unexpectedAtRootLevel(token)
            case .form(let formTokens):
                do {
                    var tokens = formTokens
                    var localVariables: [Variable] = []

                    guard case .atom(let zil) = tokens.shift() else {
                        throw GameError.unknownDirective(tokens)
                    }

                    if let factory = try Game.findFactory(zil, root: true)?.init(
                        tokens, with: &localVariables
                    ) {
                        _ = try factory.process()
                    } else {
                        let factory = try Factories.RoutineCall(formTokens, with: &localVariables)
                        _ = try factory.process()
                    }

                    progressBar.next()

                } catch {
                    var description = ""
                    customDump(error, to: &description)

                    Logger.process.warning("\(description, privacy: .public)")

                    errors.append("\(description)")

                    unprocessedTokens.append(token)
                }
            default:
                break // ignored
            }
        }
        self.tokens = unprocessedTokens
    }

    func setZMachineVersion() throws {
        for token in tokens {
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
