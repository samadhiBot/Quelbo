//
//  Define.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/5/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [DEFINE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.440mph5j49mp)
    /// function.
    class Define: ZilFactory {
        override class var zilNames: [String] {
            ["DEFINE"]
        }

        var nameSymbol: Symbol!
        var definition: [Token] = []

        override func processTokens() throws {
            var tokens = tokens
            self.nameSymbol = try findNameSymbol(in: &tokens)
            self.definition = tokens
        }

        override func process() throws -> Symbol {
            let symbol = Symbol(
                id: nameSymbol.id,
                category: .definitions,
                meta: [.zil(definition)]
            )
            try Game.commit(symbol)
            return symbol
        }
    }
}
