//
//  GetProperty.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GETP](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1q7ozz1)
    /// function.
    class GetProperty: Factory {
        override class var zilNames: [String] {
            ["GETP"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2))
            )

            try symbols[0].assert(
                .hasType(.object)
            )

            try symbols[1].assert(
                .isProperty
            )
        }

        override func process() throws -> Symbol {
            let object = symbols[0]
            let property = symbols[1]

            return .statement(
                code: { _ in
                    "\(object.code).\(property.code)"
                },
                type: property.type,
                payload: .init(
                    symbols: symbols
                )
            )
        }
    }
}
