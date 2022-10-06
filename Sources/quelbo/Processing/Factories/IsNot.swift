//
//  IsNot.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [NOT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3d0wewm)
    /// function.
    class IsNot: Factory {
        override class var zilNames: [String] {
            ["NOT"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1))
            )
        }

        override func process() throws -> Symbol {
            let other = symbols[0]

            return .statement(
                code: { _ in
                    ".isNot(\(other.handle))"
                },
                type: .bool
            )
        }
    }
}
