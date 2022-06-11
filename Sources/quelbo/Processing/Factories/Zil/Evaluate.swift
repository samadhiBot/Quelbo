//
//  Evaluate.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for calls to functions and routines defined in a game.
    ///
    class Evaluate: SymbolFactory {
        /// The functions or routine defined in a game.
        var routine = Symbol("TBD")

        /// The function or routine parameters.
        var params: [Symbol] = []

        override func processTokens() throws {
            var tokens = tokens
            let name = try findNameSymbol(in: &tokens).code
            self.routine = try Game.find(.init(stringLiteral: name), category: .routines)

            var symbols = try symbolize(tokens)

            self.params = try routine.children.map { (symbol: Symbol) -> Symbol in
                guard let value = symbols.shift() else {
                    throw Error.missingEvalParameter(symbol)
                }
                return symbol.with(code: "\(symbol.id): \(value.code)")
//                if routine.isFunctionClosure {
//                    return symbol.with(code: value.code)
//                } else {
//                    return symbol.with(code: "\(symbol.id): \(value)")
//                }
            }

//            {
//                self.routine = routine
//            } else {
//                let definition = try Game.find(.init(stringLiteral: name), category: .routines)
//                guard let unevaluated = definition.unevaluated else {
//                    throw FactoryError.invalidValue(definition)
//                }
////                guard let evalSymbol = try symbolize([unevaluated]).first else {
////                    throw FactoryError.evaluationFailed(unevaluated)
////                }
//                self.routine = try symbolize(unevaluated)
//            }
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(routine.id)(\(params.codeValues(.commaSeparatedNoTrailingComma)))",
                type: routine.type,
                children: params
            )
        }
    }
}

// MARK: - Errors

extension Factories.Evaluate {
    enum Error: Swift.Error {
        case missingEvalParameter(Symbol)
    }
}
