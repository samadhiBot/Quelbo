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
    class Function: Factory {
        override class var zilNames: [String] {
            ["FUNCTION"]
        }

        var blockProcessor: BlockProcessor!

        override func processTokens() throws {
            self.blockProcessor = try BlockProcessor(
                tokens,
                with: &localVariables
            )
        }

        override func process() throws -> Symbol {
            let pro = blockProcessor!

            return .statement(
                code: { _ in
                    let argNames = pro.paramDeclarations

                    return """
                        {\(argNames.isEmpty ? "" : " (\(argNames))\(try pro.returnDeclaration()) in")
                        \(pro.auxiliaryDefs.indented)\
                        \(pro.code.indented)
                        }
                        """
                },
                type: try pro.functionType(),
                isMutable: false
            )
        }
    }
}
