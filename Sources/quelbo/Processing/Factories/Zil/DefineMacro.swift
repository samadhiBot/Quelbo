//
//  DefineMacro.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/2/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [DEFMAC](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.206ipza)
    /// function.
    class DefineMacro: ZilFactory {
        override class var zilNames: [String] {
            ["DEFMAC"]
        }

        var nameSymbol: Symbol!
        var pro: BlockProcessor!

        override func processTokens() throws {
            var tokens = tokens
            self.nameSymbol = try findNameSymbol(in: &tokens)
            self.pro = try BlockProcessor(tokens, in: .blockWithDefaultActivation)
        }

        override func process() throws -> Symbol {
            print("  + Processing macro \(nameSymbol.code)")

            let symbol = Symbol(
                id: nameSymbol.code,
                code: """
                    \(pro.discardableResult)\
                    /// The `\(nameSymbol.code)` (\(nameSymbol.id)) macro.
                    func \(nameSymbol.code)(\(pro.params))\(pro.returnValue) {
                    \(pro.warningComments(indented: true))\
                    \(pro.auxiliaryDefs(indented: true))\
                    \(pro.codeBlock.indented)
                    }
                    """,
                type: pro.type,
                category: .routines,
                children: pro.params.children
//                meta: [.unevaluated()]
            )
            try Game.commit(symbol)
            return symbol
        }
    }
}
