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
            self.pro = try BlockProcessor(tokens, in: .blockWithDefaultActivation)
        }

        var codeBlock: String {
            if pro.isRepeating {
                return """
                    \(pro.deepParameters)\
                    \(pro.activation)\
                    while true {
                    \(pro.auxiliaryDefsWithDefaultValues(indented: true))\
                    \(pro.codeBlock.indented)
                    }
                    """
            } else {
                return """
                    \(pro.auxiliaryDefsWithDefaultValues())\
                    \(pro.codeBlock)
                    """
            }
        }

        override func process() throws -> Symbol {
            print("  + Processing routine \(nameSymbol.code)")

            let symbol = Symbol(
                id: nameSymbol.code,
                code: """
                    \(pro.discardableResult)\
                    /// The `\(nameSymbol.code)` (\(nameSymbol.id)) routine.
                    func \(nameSymbol.code)(\(pro.params))\(pro.returnValue) {
                    \(pro.warningComments(indented: true))\
                    \(pro.auxiliaryDefs(indented: true))\
                    \(codeBlock.indented)
                    }
                    """,
                type: pro.type,
                category: .routines,
                children: pro.params.children
            )
            try Game.commit(symbol)
            return symbol
        }
    }
}
