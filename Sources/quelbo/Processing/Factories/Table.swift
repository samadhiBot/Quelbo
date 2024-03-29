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

            self.flags = try findFlags(in: &tokens)

            symbols.append(contentsOf: try symbolize(tokens))
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(1)),
                .haveKnownType,
                .areTableElements
            )
        }

        override func process() throws -> Symbol {
            let flagSymbol = flagSymbol

            return .statement(
                code: {
                    var elementValues = $0.payload.symbols
                    let singleType = elementValues.returnTypes.count <= 1
                    if let flagSymbol {
                        elementValues.append(flagSymbol)
                    }
                    let tableValues = elementValues.codeValues(
                        .commaSeparatedNoTrailingComma,
                        forceSingleType: singleType
                    )

                    if $0.type.isTableElement == true {
                        return ".table(\(tableValues))"
                    } else {
                        return "Table(\(tableValues))"
                    }
                },
                type: .table,
                payload: .init(
                    flags: flags,
                    symbols: symbols
                ),
                isMutable: !flags.contains(.pure)
            )
        }
    }
}

extension Factories.Table {
    func findFlags(in tokens: inout [Token]) throws -> [Fizmo.Table.Flag] {
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

        return tableFlags.unique.sorted()
    }

    var flagSymbol: Symbol? {
        let flagValues = flags
            .map { ".\($0)" }
            .values(.commaSeparatedNoTrailingComma)

        guard !flagValues.isEmpty else { return nil }

        return .statement(
            code: { _ in
                "flags: \(flagValues)"
            },
            type: .someTableElement
        )
    }
}

extension Factories.Table {
    enum Error: Swift.Error {
        case invalidTableFlags([Token])
    }
}
