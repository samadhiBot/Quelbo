//
//  RoutineCall.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for user-defined routine calls.
    class RoutineCall: SymbolFactory {
        override func process() throws -> Symbol {
            var tokens = tokens
            let routineName = try findNameSymbol(in: &tokens).code

            var symbols = try symbolize(tokens)
            let routine = try Game.find(routineName, category: .routines)

            let params = try routine.children.map { (symbol: Symbol) -> Symbol in
                guard let value = symbols.shift() else {
                    throw FactoryError.missingParameter(symbol)
                }
                return symbol.with(code: "\(symbol.id): \(value)")
            }

            return Symbol(
                id: routineName,
                code: "\(routineName)(\(params.codeValues(separator: ",")))",
                type: routine.type,
                children: params
            )
        }
    }
}
