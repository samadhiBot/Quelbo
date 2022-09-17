//
//  GetValue.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [VALUE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4j8vrz3)
    /// function.
    class GetValue: Factory {
        override class var zilNames: [String] {
            ["VALUE"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1))
            )
        }

        override func process() throws -> Symbol {
            let variable = symbols[0]

            return .statement(
                code: { _ in
                    variable.code
                },
                type: variable.type
            )
        }
    }
}
