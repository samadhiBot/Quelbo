//
//  Buzz.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [BUZZ](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.ihv636)
    /// function.
    class Buzz: Factory {
        override class var zilNames: [String] {
            ["BUZZ"]
        }

        override func processTokens() throws {
            self.symbols = try symbolizeAtomsToStrings(tokens)
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(1))
            )
        }

        override func process() throws -> Symbol {
            let buzzwords = symbols.map(\.code)

            return .statement(
                code: { _ in
                    """
                    Syntax.ignore([\(buzzwords.values(.commaSeparated))])
                    """
                },
                type: .void,
                category: .syntax,
                isCommittable: true
            )
        }
    }
}
