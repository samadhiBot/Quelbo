//
//  Print.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/2/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PRINT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.kqmvb9)
    /// [PRINTB](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.34qadz2)
    /// [PRINTC](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1jvko6v)
    /// [PRINTI](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.y5sraa) and
    /// functions.
    class Print: Factory {
        override class var zilNames: [String] {
            ["PRINT", "PRINTB", "PRINC", "PRINTI"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1))
            )

            try symbols[0].assert(
                .hasReturnValue
            )

            try? symbols[0].assert(
                .hasType(.string)
            )
        }

        override func process() throws -> Symbol {
            let string = symbols[0]

            return .statement(
                code: { _ in
                    "output(\(string.handle))"
                },
                type: .void,
                payload: .init(symbols: symbols)
            )
        }
    }
}
