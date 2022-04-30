//
//  RoutineCall.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for calls to user-defined routines.
    ///
    class RoutineCall: SymbolFactory {
        /// The user-defined routine that is being called.
        var routine: Symbol = Symbol("TBD")

        /// The user-defined routine parameters.
        var params: [Symbol] = []

        override func processTokens() throws {
            var tokens = tokens
            let routineName = try findNameSymbol(in: &tokens).code

            var symbols = try symbolize(tokens)
            self.routine = try Game.find(routineName, category: .routines)

            self.params = try routine.children.map { (symbol: Symbol) -> Symbol in
                guard let value = symbols.shift() else {
                    throw FactoryError.missingParameter(symbol)
                }
                return symbol.with(code: "\(symbol.id): \(value)")
            }
        }

        override func process() throws -> Symbol {
            Symbol(
                id: routine.id,
                code: "\(routine.id)(\(params.codeValues(separator: ",")))",
                type: routine.type,
                children: params
            )
        }
    }
}
