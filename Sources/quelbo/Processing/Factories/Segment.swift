//
//  Segment.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/3/22.
//

import Foundation

extension Factories {
    /// A symbol factory for Zil
    /// [Segment](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.9p1vu0r47dql)
    /// types.
    class Segment: Factory {
        override func processTokens() throws {
            do {
                try super.processTokens()
            } catch GameError.globalNotFound(id: _, zil: let zil) {
                symbols.append(
                    try Factories.Global(
                        [.atom(zil), .bool(false)],
                        with: &localVariables,
                        mode: mode
                    ).processOrEvaluate()
                )
            }
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(1)))
        }

        override func process() throws -> Symbol {
            symbols[0]
        }
    }
}
