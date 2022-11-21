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

            localVariables.append(.init(
                id: zilName,
                code: { _ in "" },
                type: .unknown,
                isFunctionCall: true
            ))

            self.blockProcessor = try Factories.BlockProcessor(
                tokens,
                with: &localVariables
            )
        }

        override func process() throws -> Symbol {
            let name = zilName.lowerCamelCase
            let typeName = isMacro ? "macro" : "routine"
            let zilName = zilName!

            return .statement(
                id: name,
                code: {
                    """
                        \($0.payload.discardableResult)\
                        /// The `\(name)` (\(zilName)) \(typeName).
                        func \(name)\
                        (\($0.payload.paramDeclarations))\
                        \($0.payload.returnDeclaration) \
                        {
                        \($0.payload.auxiliaryDefs.indented)\
                        \($0.payload.codeHandlingRepeating.indented)
                        }
                        """
                },
                type: blockProcessor.payload.returnType ?? .void,
                payload: blockProcessor.payload,
                category: .routines,
                isCommittable: true
            )
        }
    }
}
