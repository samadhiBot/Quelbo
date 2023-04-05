//
//  PutProperty.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PUTP](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.48zs1w5)
    /// function.
    class PutProperty: Factory {
        override class var zilNames: [String] {
            ["PUTP"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(3))
            )

            try symbols[0].assert(
                .hasType(.object)
            )
        }

        override func process() throws -> Symbol {
            let object = symbols[0]
            let property = symbols[1]
            let value = symbols[2]

            return .statement(
                code: { _ in
                    "\(object.chainingID).\(property.handle) = \(value.handle)"
                },
                type: .void,
                returnHandling: .suppressed
            )
        }
    }
}
