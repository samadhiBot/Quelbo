//
//  Function.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [FUNCTION](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.m3e5asphu6rd)
    /// function.
    class Function: MuddleFactory {
        override class var zilNames: [String] {
            ["FUNCTION"]
        }

        var blockProcessor: BlockProcessor!

        override func processTokens() throws {
            self.blockProcessor = try BlockProcessor(
                tokens,
                in: .blockWithDefaultActivation,
                with: &registry
            )
        }

        override func process() throws -> Symbol {
            Symbol(
                code: codeBlock,
                type: blockProcessor.type,
                children: blockProcessor.children,
                meta: blockProcessor.metaData.union([
                    .isImmutable,
                    .type("(\(blockProcessor.argumentTypes))\(blockProcessor.returnValue)"),
                ])
            )
        }
    }
}

extension Factories.Function {
    var codeBlock: (Symbol) throws -> String {
        { symbol in
            var pro = Symbol.BlockPro(for: symbol)
            let argNames = pro.paramsSymbol.children.codeValues(.commaSeparated)

            return """
                {\(argNames.isEmpty ? "" : " (\(argNames))\(pro.returnValue) in")
                \(pro.auxiliaryDefs(indented: true))\
                \(pro.codeBlock().indented)
                }
                """
        }
    }
}
