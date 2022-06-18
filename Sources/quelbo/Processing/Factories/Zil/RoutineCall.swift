//
//  RoutineCall.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for calls to functions and routines defined in a game.
    ///
    class RoutineCall: SymbolFactory {
        /// The functions or routine defined in a game.
        var routine = Symbol("TBD")

        /// The function or routine parameters.
        var params: [Symbol] = []

        override func processTokens() throws {
            var tokens = tokens
            let nameSymbol = try findNameSymbol(in: &tokens)
            if let routine = try? Game.find(.id(nameSymbol.code), category: .routines) {
                self.routine = routine
            } else {
                self.routine = try Game.find(evalID(self.tokens), category: .functions)
                                       .with(id: .id(nameSymbol.code))
            }

            var paramSymbols = try symbolize(tokens)
            self.params = routine.children.compactMap { symbol in
                guard let value = paramSymbols.shift() else {
                    return nil
                }
                return symbol.with(code: "\(symbol.id): \(value.code)")
            }
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

extension Factories.RoutineCall {
    enum Error: Swift.Error {
        case missingRoutineParameter(Symbol)
    }
}
