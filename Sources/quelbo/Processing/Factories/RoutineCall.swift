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
    class RoutineCall: Factory {
        /// The functions or routine defined in a game.
        var routine: Statement!

        /// The function or routine parameters.
        var params: [Symbol] = []

        override func processTokens() throws {
            var routineTokens = tokens

            let name = try findName(in: &routineTokens).lowerCamelCase

            if let routine = Game.routines.find(name) {
                self.routine = routine
            } else if let function = Game.routines.find(try evalID(tokens)) {
                self.routine = function
            } else {
                throw Error.unknownRoutine(name, routineTokens)
            }

            var paramSymbols = try symbolize(routineTokens)

            self.params = routine.parameters.compactMap { symbol in
                guard let value = paramSymbols.shift() else { return nil }

                return .statement(
                    code: { _ in
                        "\(symbol.code): \(value.code)"
                    },
                    type: value.type
                )
            }
        }

        override func process() throws -> Symbol {
            guard
                let routine = routine,
                let routineName = routine.id?.split(separator: "(").first
            else {
                throw Error.unknownRoutineName(symbols)
            }
            let params = params

            return .statement(
                code: { _ in
                    "\(routineName)(\(params.codeValues(.commaSeparatedNoTrailingComma)))"
                },
                type: routine.type
            )
        }
    }
}

// MARK: - Errors

extension Factories.RoutineCall {
    enum Error: Swift.Error {
        case unknownRoutine(String, [Token])
        case unknownRoutineName([Symbol])
        case missingRoutineParameter(Symbol)
    }
}
