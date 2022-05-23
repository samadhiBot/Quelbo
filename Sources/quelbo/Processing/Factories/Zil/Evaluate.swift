//
//  Evaluate.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for calls to user-defined routines.
    ///
    class Evaluate: SymbolFactory {
        /// The user-defined routine that is being called.
        var routine = Symbol("TBD")

        /// The user-defined routine parameters.
        var params: [Symbol] = []

        override func processTokens() throws {
            var tokens = tokens
            let name = try findNameSymbol(in: &tokens).code

            var symbols = try symbolize(tokens)

            if let routine = try? Game.find(name, category: .routines) {
                self.routine = routine
            } else {
                let definition = try Game.find(name, category: .definitions)
                guard let unevaluated = definition.unevaluated else {
                    throw FactoryError.invalidValue(definition)
                }
//                guard let evalSymbol = try symbolize([unevaluated]).first else {
//                    throw FactoryError.evaluationFailed(unevaluated)
//                }
                self.routine = try symbolize(unevaluated)
            }

            self.params = try routine.children.map { (symbol: Symbol) -> Symbol in
                guard let value = symbols.shift() else {
                    throw FactoryError.missingParameter(symbol)
                }
                if routine.isFunctionClosure {
                    return symbol.with(code: value.code)
                } else {
                    return symbol.with(code: "\(symbol.id): \(value)")
                }
            }
        }

        override func process() throws -> Symbol {
            Symbol(
                id: routine.id,
                code: "\(routine.id)(\(params.codeValues(.commaSeparatedNoTrailingComma)))",
                type: routine.type,
                children: params
            )
        }
    }
}
