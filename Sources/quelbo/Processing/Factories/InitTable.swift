//
//  InitTable.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import Fizmo
import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ITABLE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3s49zyc)
    /// function.
    class InitTable: Table {
        override class var zilNames: [String] {
            ["ITABLE"]
        }

        var defaults: [Symbol] = []

        override func processTokens() throws {
            var tokens = tokens

            fetchSpecifiers(&tokens).forEach { flags.append($0) }

            guard let count = tokens.shift() else {
                throw Error.missingCount
            }

            self.flags = try findFlags(in: &tokens)
            self.defaults = try symbolize(tokens)

            symbols.append(.statement(
                code: { _ in
                    "count: \(count.value.lowerCamelCase)"
                },
                type: .int
            ))

            if !defaults.isEmpty {
                self.symbols.append(
                    .statement(
                        code: { statement in
                            let defaultValues = statement.payload.symbols
                                .codeValues(.commaSeparatedNoTrailingComma)
                            return "defaults: \(defaultValues)"
                        },
                        type: .someTableElement,
                        payload: .init(
                            symbols: defaults
                        )
                    )
                )
            }
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(0)),
                .areTableElements
            )

            try defaults.assert(
                .areTableElements
            )
        }
    }
}

extension Factories.InitTable {
    enum Error: Swift.Error {
        case missingCount
    }

    /*
     <ITABLE [specifier] count [(flags...)] defaults ...>

         ZIL library

     Defines a table of count elements filled with default values: either zeros or, if the default list is specified, the specified list of values repeated until the table is full.
     The optional specifier may be the atoms NONE, BYTE, or WORD. BYTE and WORD change the type of the table and also turn on the length marker (element 0 in the table contains the length of the table), This can also be done with the flags (see TABLE about flags).

     <ITABLE 4 0>
     <ITABLE (BYTE LENGTH) 4 0>
     <ITABLE BYTE 4 0>
     <ITABLE NONE 100>
     <ITABLE 59 (LEXV) 0 #BYTE 0 #BYTE 0>
     <ITABLE NONE ,READBUF-SIZE (BYTE)>

     */

    func fetchSpecifiers(_ tokens: inout [Token]) -> [Table.Flag] {
        var flags: [Table.Flag] = []

        switch tokens.first {
        case .atom("BYTE"):
            flags = [.byte, .length]
        case .atom("WORD"):
            flags = [.word, .length]
        case .atom("NONE"):
            flags = [.none]
            break
        case .list(let specifiers):
            flags = specifiers.reduce(into: [], { result, token in
                var inner = [token]
                result.append(contentsOf: fetchSpecifiers(&inner))
            })
        default:
            return []
        }
        tokens.removeFirst()
        return flags
    }
}
