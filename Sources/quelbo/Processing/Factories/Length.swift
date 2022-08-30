//
//  Length.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LENGTH](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.zu0gcz)
    /// function.
    class Length: Factory {
        override class var zilNames: [String] {
            ["LENGTH"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(1)))
        }

        override func process() throws -> Symbol {
            let collection = symbols[0]

            return .statement(
                code: { _ in
                    "\(collection.code).count"
                },
                type: .int,
                confidence: .certain
            )
        }
    }
}
