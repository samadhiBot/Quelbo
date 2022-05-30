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
            self.pro = try BlockProcessor(tokens, in: .blockWithDefaultActivation, with: types)
        }

        var codeBlock: String {
            if pro.isRepeating {
                return """
                    \(pro.paramDeclarations())\
                    \(pro.activation)\
                    while true {
                    \(pro.code.code.indented)
                    }
                    """
            } else {
                return """
                    do {
                    \(pro.paramDeclarations(indented: true))\
                    \(pro.code.code.indented)
                    }
                    """
            }
        }

        override func process() throws -> Symbol {
            Symbol(
                id: "<Block>",
                code: codeBlock,
                type: pro.type,
                children: pro.children,
                meta: pro.metaData
            )
        }
    }
}
