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
        var blockProcessor: BlockProcessor!

        override func processTokens() throws {
            var tokens = tokens
            self.nameSymbol = try findNameSymbol(in: &tokens)
            self.blockProcessor = try BlockProcessor(tokens, with: &registry)
        }

        var typeName: String {
            "routine"
        }

        override func process() throws -> Symbol {
            let symbol = Symbol(
                id: nameSymbol.id,
                code: codeBlock,
                type: blockProcessor.type,
                category: .routines,
                children: blockProcessor.children,
                meta: blockProcessor.metaData
            )
            Game.commit(symbol)
            return symbol
        }
    }
}

extension Factories.Routine {
    var codeBlock: (Symbol) throws -> String {
        let nameSymbol = nameSymbol!
        let typeName = typeName

        return { symbol in
            let pro = Symbol.BlockPro(for: symbol)

            print(
                """
                // 🍒 Factories.Routine codeBlock:

                \(pro.discardableResult)\
                /// The `\(nameSymbol)` (\(nameSymbol.zilName)) \(typeName).
                func \(nameSymbol)\
                (\(pro.normalAndOptionalParams.codeValues(.commaSeparatedNoTrailingComma)))\
                \(pro.returnValue) \
                {
                \(pro.auxiliaryDefs(indented: true))\
                \(pro.codeBlock().indented)
                }
                
                """
            )
            return """
                \(pro.discardableResult)\
                /// The `\(nameSymbol)` (\(nameSymbol.zilName)) \(typeName).
                func \(nameSymbol)\
                (\(pro.normalAndOptionalParams.codeValues(.commaSeparatedNoTrailingComma)))\
                \(pro.returnValue) \
                {
                \(pro.auxiliaryDefs(indented: true))\
                \(pro.codeBlock().indented)
                }
                """
        }
    }
}
