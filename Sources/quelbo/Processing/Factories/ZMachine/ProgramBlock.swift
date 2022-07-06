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
        var blockRegistry: [Symbol] = []

        var controlFlow: Symbol.MetaData.ControlFlow {
            .block(activation: tokens.hash)
        }

        var defaultActivation: String? {
            tokens.hash
        }

        override func processTokens() throws {
            self.blockProcessor = try BlockProcessor(
                tokens,
                with: &blockRegistry,
                autoProcessTokens: false
            )
            blockProcessor.blockActivation = self.defaultActivation
            try blockProcessor.processTokens()

            print("// 🌽 blockRegistry: \(blockRegistry)\nregistry: \(registry)")
        }

        override func process() throws -> Symbol {
            Symbol(
                code: codeBlock,
                type: blockProcessor.type,
                children: blockProcessor.children,
                meta: blockProcessor.metaData.union([
                    .controlFlow(controlFlow)
                ])
            )
        }
    }
}

extension Factories.ProgramBlock {
    var codeBlock: (Symbol) throws -> String {
        { symbol in
            let pro = Symbol.BlockPro(for: symbol)
            let activationCode = pro.activationCode

            if pro.codeSymbol.isRepeating, !activationCode.isEmpty {
                print("// 🍇 ProgramBlock: \(pro.codeSymbol.code)")
                return """
                    \(pro.paramDeclarations())\
                    \(activationCode)\
                    while true {
                    \(pro.codeSymbol.code.indented)
                    }
                    """
            } else {
                print("// 🍇 ProgramBlock: (no-repeat) \(pro.codeSymbol.code)")
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
