//
//  Routine.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/2/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ROUTINE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.22vxnjd)
    /// function.
    class Routine: ZilFactory {
        override class var zilNames: [String] {
            ["ROUTINE"]
        }

        var nameSymbol: Symbol!
        var pro: BlockProcessor!

        override func processTokens() throws {
            var tokens = tokens
            self.nameSymbol = try findNameSymbol(in: &tokens)
            self.pro = try BlockProcessor(tokens, in: .blockWithDefaultActivation, with: registry)
        }

        var typeName: String {
            "routine"
        }

        override func process() throws -> Symbol {
            let symbol = Symbol(
                id: nameSymbol.id,
                code: """
                    \(pro.discardableResult)\
                    /// The `\(nameSymbol.id)` (\(nameSymbol.zilName)) \(typeName).
                    func \(nameSymbol.id)(\(pro.paramsSymbol.code))\(pro.returnValue) {
                    \(pro.warningComments(indented: true))\
                    \(pro.auxiliaryDefs(indented: true))\
                    \(pro.codeBlock.indented)
                    }
                    """,
                type: pro.type,
                category: .routines,
                children: pro.paramsSymbol.children
            )
            try Game.commit(symbol)
            return symbol
        }
    }
}
