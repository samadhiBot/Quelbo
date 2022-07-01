//
//  ProgramBlock.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PROG](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1bkyn9b)
    /// function.
    class ProgramBlock: ZMachineFactory {
        override class var zilNames: [String] {
            ["PROG"]
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
                meta: blockProcessor.metaData
            )
        }
    }
}

extension Factories.ProgramBlock {
    var codeBlock: (Symbol) throws -> String {
        { symbol in
            let pro = Symbol.BlockPro(for: symbol)

            if pro.isRepeating {
                return """
                    \(pro.paramDeclarations())\
                    \(pro.activation)\
                    while true {
                    \(pro.codeSymbol.code.indented)
                    }
                    """
            } else {
                return """
                    do {
                    \(pro.paramDeclarations(indented: true))\
                    \(pro.codeSymbol.code.indented)
                    }
                    """
            }
        }
    }
}
