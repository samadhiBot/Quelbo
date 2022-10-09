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
    ///
    /// In practice, anonymous functions in Zil only seem to occur in a ``MapFirst`` context.
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
            let name = "anon\(tokens.miniHash)"
            let pro = blockProcessor!
            let type = pro.returnType() ?? .void

            return .statement(
                id: name,
                code: { _ in
                    """
                    func \(name)\
                    (\(pro.paramDeclarations))\
                    \(try pro.returnDeclaration()) \
                    {
                    \(pro.auxiliaryDefs.indented)\
                    \(pro.codeHandlingRepeating.indented)
                    }
                    """
                },
                type: type,
                parameters: pro.paramSymbols,
                children: pro.symbols,
                isAnonymousFunction: true,
                isMutable: false
            )
        }
    }
}
