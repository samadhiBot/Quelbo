//
//  Table.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/7/22.
//

import Fizmo
import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [TABLE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2kz067v)
    /// function.
    class Table: Factory {
        override class var zilNames: [String] {
            ["TABLE"]
        }

        var presetFlags: [Fizmo.Table.Flag] {
            []
        }

        var flags: [Fizmo.Table.Flag] = []

        override func processTokens() throws {
            var tokens = tokens
            if let flagSymbol = try findFlagSymbol(in: &tokens) {
                symbols.append(flagSymbol)
            }
            symbols.append(contentsOf: try symbolize(tokens))
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.atLeast(2)),
                .haveType(.zilElement),
            ])
        }

        override func process() throws -> Symbol {
            .statement(
                code: { statement in
                    let elementValues = statement.children
                        .codeValues(.commaSeparatedNoTrailingComma)

                    if statement.quirk == .zilElement {
                        return ".table(Table(\(elementValues)))"
                    } else {
                        return "Table(\(elementValues))"
                    }
                },
                type: .table,
                confidence: .certain,
                children: symbols,
                isMutable: !flags.contains(.pure)
            )
        }
    }
}

extension Factories.Table {
    func findFlagSymbol(in tokens: inout [Token]) throws -> Symbol? {
        var tableFlags = flags + presetFlags

        if case .list(let flagTokens) = tokens.first {
            tokens.removeFirst()
            let fizmoFlags: [Fizmo.Table.Flag] = flagTokens.compactMap {
                Fizmo.Table.Flag(rawValue: $0.value.lowerCamelCase)
            }
            switch fizmoFlags.count {
            case 0:
                break
            case flagTokens.count:
                tableFlags.append(contentsOf: fizmoFlags)
            default:
                throw Factories.Table.Error.invalidTableFlags(flagTokens)
            }
        }

        self.flags = tableFlags
            .unique
            .sorted { $0.rawValue < $1.rawValue }

        let flagValues = flags
            .map { ".\($0)" }
            .values(.commaSeparated)
        guard !flagValues.isEmpty else { return nil }

        return .statement(
            code: { _ in
                "flags: [\(flagValues)]"
            },
            type: .zilElement,
            confidence: .certain
        )
    }
}

extension Factories.Table {
    enum Error: Swift.Error {
        case invalidTableFlags([Token])
    }
}
