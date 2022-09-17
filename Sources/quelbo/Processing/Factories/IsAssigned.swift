//
//  IsAssigned.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ASSIGNED?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.393x0lu)
    /// function.
    class IsAssigned: Factory {
        override class var zilNames: [String] {
            ["ASSIGNED?"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1))
            )

            try symbols[0].assert(
                .isVariable
            )
        }

        override func process() throws -> Symbol {
            let argument = symbols[0]

            return .statement(
                code: { _ in
                    "\(argument.code).isAssigned"
                },
                type: .bool
            )
        }
    }
}
