//
//  PropertySize.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PTSIZE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2apwg4x)
    /// function.
    class PropertySize: Factory {
        override class var zilNames: [String] {
            ["PTSIZE"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1))
            )

            try symbols[0].assert(
                .hasType(.object)
            )
        }

        override func process() throws -> Symbol {
            let object = symbols[0]

            return .statement(
                code: { _ in
                    "\(object.handle).propertySize"
                },
                type: .int
            )
        }
    }
}
