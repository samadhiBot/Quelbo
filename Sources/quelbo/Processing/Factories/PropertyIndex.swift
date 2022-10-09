//
//  PropertyIndex.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GETPT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4a7cimu)
    /// function.
    class PropertyIndex: Factory {
        override class var zilNames: [String] {
            ["GETPT"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2))
            )

            try symbols[0].assert(
                .hasType(.object)
            )
        }

        override func process() throws -> Symbol {
            let object = symbols[0]
            let property = symbols[1]

            return .statement(
                code: { _ in
                    "\(object.code).propertyIndex(of: .\(property.code))"
                },
                type: .int
            )
        }
    }
}
