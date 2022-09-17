//
//  Again.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/24/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [AGAIN](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1au1eum)
    /// function.
    class Again: Factory {
        override class var zilNames: [String] {
            ["AGAIN"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.between(0...1)))
        }

        override func process() throws -> Symbol {
            var activation: String? {
                symbols.first?.code
            }

            return .statement(
                code: { statement in
                    guard let activation = statement.activation else { return "continue" }

                    return "continue \(activation)"
                },
                type: .void,
                activation: activation,
                isAgainStatement: true
            )
        }
    }
}
