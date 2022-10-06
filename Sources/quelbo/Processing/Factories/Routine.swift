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
    class Routine: Factory {
        override class var zilNames: [String] {
            ["ROUTINE"]
        }

        var blockProcessor: BlockProcessor!
        var zilName: String!

        var isMacro: Bool {
            false
        }

        override func processTokens() throws {
            var tokens = isMacro ? tokens.evaluated : tokens

            self.zilName = try findName(in: &tokens)
            self.blockProcessor = try Factories.BlockProcessor(
                tokens,
                with: &localVariables
            )
        }

        override func process() throws -> Symbol {
            let name = zilName.lowerCamelCase
            let typeName = isMacro ? "macro" : "routine"
            let zilName = zilName!
            let pro = blockProcessor!
            let type = pro.returnType() ?? .void

            return .statement(
                id: name,
                code: { _ in
                    """
                    \(try pro.discardableResult())\
                    /// The `\(name)` (\(zilName)) \(typeName).
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
                category: .routines,
                isCommittable: true
            )
        }
    }
}
