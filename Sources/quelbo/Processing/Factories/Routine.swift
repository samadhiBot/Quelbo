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

        override func processSymbols() throws {
            try blockProcessor.symbols.assert(
                .haveSingleReturnType
            )
        }

        override func process() throws -> Symbol {
            let isMacro = isMacro
            let name = zilName.lowerCamelCase
            let zilName = zilName!

            guard Game.findFactory(zilName) == nil else {
                return .emptyStatement
            }

            return .statement(
                id: name,
                code: { statement in
                    let payload = statement.payload
                    var typeName: String {
                        if isMacro { return "macro" }
                        return statement.isActionRoutine ? "action routine" : "routine"
                    }

                    return """
                        \(payload.discardableResult)\
                        /// The `\(name)` (\(zilName)) \(typeName).
                        func \(name)\
                        (\(payload.paramDeclarations))\
                        \(payload.throwsDeclaration)\
                        \(payload.returnDeclaration) \
                        {
                        \(payload.auxiliaryDefs.indented)\
                        \(payload.codeHandlingRepeating.indented)
                        }
                        """
                },
                type: blockProcessor.payload.returnType ?? .void,
                payload: blockProcessor.payload,
                category: .routines,
                isActionRoutine: Game.shared.actionIDs.contains(name),
                isCommittable: true,
                isThrowing: blockProcessor.payload.symbols.containThrowingStatement,
                returnHandling: .passthrough
            )
        }
    }
}
