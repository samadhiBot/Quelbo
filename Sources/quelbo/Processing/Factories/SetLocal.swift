//
//  SetLocal.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/4/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [SET](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.27jua8u)
    /// function.
    class SetLocal: Factory {
        override class var zilNames: [String] {
            ["SET"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2)),
                .haveCommonType
            )

            try symbols[1].assert(
                .hasReturnValue
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
                    "\(variable.handle).set(to: \(value.handle))"
                },
                type: value.type
            )
        }
    }
}
