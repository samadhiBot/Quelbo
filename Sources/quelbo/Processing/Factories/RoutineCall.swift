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
        /// A trailing comment, used by subclass factories.
        var comment: String { "" }

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

            self.params = routine.payload.parameters.compactMap { symbol in
                guard let value = paramSymbols.shift() else { return nil }

                return .statement(
                    code: { _ in
                        "\(symbol.id): \(value.handle)"
                    },
                    type: value.type
                )
            }
        }

        override func evaluate() throws -> Symbol {
            try process()
        }

        override func process() throws -> Symbol {
            guard
                let routine = routine,
                let routineID = routine.id
            else {
                throw Error.unknownRoutineName(symbols)
            }
            let comment = params.isEmpty ? "" : comment
            let params = params

            return .statement(
                id: routineID,
                code: { _ in
                    "\(routineID)(\(params.handles(.commaSeparatedNoTrailingComma)))\(comment)"
                },
                type: routine.type,
                isFunctionCall: true
            )
        }
    }
}

// MARK: - Errors

extension Factories.RoutineCall {
    enum Error: Swift.Error {
        case unknownRoutine(String, [Token])
        case unknownRoutineName([Symbol])
    }
}
