//
//  LengthEquals.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LENGTH?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.zu0gcz)
    /// function.
    class LengthEquals: Factory {
        override class var zilNames: [String] {
            ["LENGTH?"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(2)))

            try symbols[0].assert(
                .isArray
            )

            try symbols[1].assert(
                .hasType(.int)
            )
        }
        
        override func process() throws -> Symbol {
            let container = symbols[0]
            let length = symbols[1]

            return .statement(
                code: { _ in
                    "\(container.code).count == \(length.code)"
                },
                type: .bool
            )
        }
    }
}
