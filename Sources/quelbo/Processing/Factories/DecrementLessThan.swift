//
//  DecrementLessThan.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [DLESS?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.35xuupr)
    /// function.
    class DecrementLessThan: Factory {
        override class var zilNames: [String] {
            ["DLESS?"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2)),
                .haveType(.int)
            )

            try symbols[0].assert(
                .isMutable,
                .isVariable
            )
        }

        override func process() throws -> Symbol {
            let variable = symbols[0]
            let value = symbols[1]

            return .statement(
                code: { _ in
                    "\(variable.code).decrement().isLessThan(\(value.code))"
                },
                type: .bool
            )
        }
    }
}
