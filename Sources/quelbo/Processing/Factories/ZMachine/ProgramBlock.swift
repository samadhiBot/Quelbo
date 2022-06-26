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

        var pro: BlockProcessor!

        override func processTokens() throws {
            self.pro = try BlockProcessor(tokens, in: .blockWithDefaultActivation, with: registry)
        }

        var codeBlock: (Symbol) throws -> String {
            let activation = pro.activation
            let isRepeating = pro.isRepeating

            return { symbol in
                let code = symbol.children[0].code
                let paramDeclarations = symbol.children[1]
                    .children
                    .map { $0.localVariable }
                    .joined(separator: "\n")
                    .appending("\n")
                if isRepeating {
                    return """
                        \(paramDeclarations)\
                        \(activation)\
                        while true {
                        \(code.indented)
                        }
                        """
                } else {
                    return """
                        do {
                        \(paramDeclarations.indented))\
                        \(code.indented)
                        }
                        """
                }
            }
        }

        override func process() throws -> Symbol {
            Symbol(
                code: codeBlock,
                type: pro.type,
                children: pro.children,
                meta: pro.metaData
            )
        }
    }
}
