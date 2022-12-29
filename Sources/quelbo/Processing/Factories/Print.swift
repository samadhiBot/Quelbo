//
//  Print.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/2/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PRINT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.kqmvb9),
    /// [PRINTB](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.34qadz2), and
    /// [PRINTI](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.y5sraa)
    /// functions.
    class Print: Factory {
        override class var zilNames: [String] {
            ["PRINT", "PRINTB", "PRINTI", "PRINC"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1)),
                .haveType(.oneOf([.int, .string, .tableElement]))
            )

            try? symbols.assert(
                .haveType(.string)
            )
        }

        override func process() throws -> Symbol {
            let string = symbols[0]

            return .statement(
                code: { _ in
                    "output(\(string.code))"
                },
                type: .void
            )
        }
    }
}
