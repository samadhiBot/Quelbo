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
        var unevaluated: [Token] = []

        override func processTokens() throws {
            var tokens = tokens
            self.nameSymbol = try findNameSymbol(in: &tokens)
            self.unevaluated = tokens
        }

        override func process() throws -> Symbol {
            print("  + Processing \(nameSymbol.code) definition")

            let symbol = Symbol(
                id: .init(stringLiteral: nameSymbol.code),
                category: .definitions,
                meta: [
                    .eval(
                        .form([.atom("FUNCTION")] + unevaluated)
                    )
                ]
            )
            try Game.commit(symbol)
            return symbol
        }
    }
}
