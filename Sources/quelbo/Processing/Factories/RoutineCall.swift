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

            let zilName = try findName(in: &routineTokens).lowerCamelCase

            guard let routine = Game.routines.find(zilName) else {
                throw Error.unknownRoutine(zilName, routineTokens)
            }
            self.routine = routine
            
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

        @discardableResult
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
                    "\(routineName)(\(params.handles(.commaSeparatedNoTrailingComma)))"
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
