//
//  DefinitionEval.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for calls to functions and routines defined in a game.
    ///
    class DefinitionEval: SymbolFactory {
        var nameSymbol: Symbol!
        var pro: BlockProcessor!

        override func processTokens() throws {
            var callerParams = tokens
            self.nameSymbol = try findNameSymbol(in: &callerParams)
            let defSymbol = try Game.find(.id(nameSymbol.code), category: .definitions)

            var definition = defSymbol.definition

            var activation: String?
            if case .atom(let act) = definition.first {
                activation = act
                definition.removeFirst()
            }

            guard case .list(var defParams) = definition.shift() else {
                throw Error.definitionParametersNotFound(definition)
            }
            for substitution in zip(defParams, callerParams) {
                defParams = try defParams.deepReplacing(substitution.0, with: substitution.1)
                definition = try definition.deepReplacing(substitution.0, with: substitution.1)
            }

            definition.insert(.list(defParams), at: 0)
            if let activation = activation {
                definition.insert(.atom(activation), at: 0)
            }

            self.pro = try BlockProcessor(definition, with: registry)
        }

        override func process() throws -> Symbol {
            let symbol = Symbol(
                id: try evalID(tokens),
                code: """
                    \(pro.discardableResult)\
                    /// The `\(nameSymbol.code)` (\(nameSymbol.id)) function.
                    func \(nameSymbol.code)(\(pro.paramsSymbol.code))\(pro.returnValue) {
                    \(pro.warningComments(indented: true))\
                    \(pro.auxiliaryDefs(indented: true))\
                    \(pro.codeBlock.indented)
                    }
                    """,
                type: pro.type,
                category: .functions,
                children: pro.paramsSymbol.children
            )
            try Game.commit(symbol)
            return symbol
        }
    }
}

// MARK: - Errors

extension Factories.DefinitionEval {
    enum Error: Swift.Error {
        case definitionParametersNotFound([Token])
    }
}
