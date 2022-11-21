//
//  Quote.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/12/22.
//

import Foundation

extension Factories {
    /// A symbol factory for Zil
    /// [QUOTE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1c1lvlb)
    /// function.
    class Quote: Factory {
        override class var zilNames: [String] {
            ["QUOTE"]
        }

        override func processTokens() throws {
            self.symbols = try symbolize(tokens, mode: .process)
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1))
            )
        }

        override func evaluate() throws -> Symbol {
            symbols[0]
        }

        override func process() throws -> Symbol {
            symbols[0]
        }
    }
}
