//
//  Put.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/1/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PUT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.39uu90j) and
    /// [PUTB](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1p04j8c)
    /// functions.
    class Put: Factory {
        override class var zilNames: [String] {
            ["PUT", "PUTB"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(3))
            )

            try symbols[0].assert(
                .hasType(.table)
            )

            try symbols[1].assert(
                .hasType(.int)
            )
        }

        override func process() throws -> Symbol {
            let table = symbols[0]
            let offset = symbols[1]
            let value = symbols[2]

            return .statement(
                code: { _ in
                    "try \(table.code).put(element: \(value.code), at: \(offset.code))"
                },
                type: value.type,
                confidence: value.confidence
            )
        }
    }
}
