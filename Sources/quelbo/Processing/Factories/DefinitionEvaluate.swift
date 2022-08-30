//
//  DefinitionEvaluate.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for calls to functions and routines defined in a game.
    ///
    class DefinitionEvaluate: Factory {
        var blockProcessor: BlockProcessor!
        var zilName: String!

        override func processTokens() throws {
            var callerParams = tokens

            self.zilName = try findName(in: &callerParams)
            let name = zilName.lowerCamelCase

            guard let rawDefinition = Game.findDefinition(name) else {
                throw Error.definitionNotFound(name)
            }
            var defTokens = rawDefinition.tokens

            var activation: String?
            if case .atom(let act) = defTokens.first {
                activation = act
                defTokens.removeFirst()
            }

            guard case .list(var defParams) = defTokens.shift() else {
                throw Error.definitionParametersNotFound(defTokens)
            }

            for substitution in zip(defParams, callerParams) {
                defParams = try defParams.deepReplacing(substitution.0, with: substitution.1)
                defTokens = try defTokens.deepReplacing(substitution.0, with: substitution.1)
            }

            defTokens.insert(.list(defParams), at: 0)
            if let activation = activation {
                defTokens.insert(.atom(activation), at: 0)
            }

            self.blockProcessor = try BlockProcessor(defTokens, with: &localVariables)
        }

        @discardableResult
        override func process() throws -> Symbol {
            let id = try evalID(tokens)
            let name = zilName.lowerCamelCase
            let zilName = zilName!
            let pro = blockProcessor!
            let (type, confidence) = try pro.returnType()

            let function: Symbol = .statement(
                id: id,
                code: { statement in
                    """
                    \(try pro.discardableResult())\
                    /// The `\(id)` (\(zilName)) function.
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
                confidence: confidence,
                parameters: pro.paramSymbols,
                children: pro.symbols,
                category: .routines
            )

            try! Game.commit(function)
            return function
        }
    }
}

// MARK: - Errors

extension Factories.DefinitionEvaluate {
    enum Error: Swift.Error {
        case definitionNotFound(String)
        case definitionParametersNotFound([Token])
        case missingDefinitionIdentifier(Symbol)
    }
}
