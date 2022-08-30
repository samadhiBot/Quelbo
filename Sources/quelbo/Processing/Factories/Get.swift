//
//  Get.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GET](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.r2r73f) and
    /// [GETB](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3b2epr8)
    /// functions.
    class Get: Factory {
        override class var zilNames: [String] {
            ["GET", "GETB"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(2)))
            try symbols[0].assert([
                .hasType(.table),
                .isVariable,
            ])
            try symbols[1].assert(.hasType(.int))
        }

        override func process() throws -> Symbol {
            let table = symbols[0]
            let offset = symbols[1]

            return .statement(
                code: { _ in
                    "try \(table.code).get(at: \(offset.code))"
                },
                type: .zilElement,
                confidence: .certain
            )
        }
    }
}
