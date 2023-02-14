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

        var zilName: String = ""

        override func processTokens() throws {
            var routineTokens = tokens

            self.zilName = try findName(in: &routineTokens)

            guard let routine = try findRoutine(zilName.lowerCamelCase) else {
                throw Error.unknownRoutine(zilName, routineTokens)
            }
            self.routine = routine
            
            var paramSymbols = try symbolize(routineTokens)

            self.params = routine.payload.parameters.compactMap { symbol in
                guard let value = paramSymbols.shift() else { return nil }

                return .statement(
                    code: {
                        guard
                            let param = $0.payload.symbols.first,
                            let value = $0.payload.symbols.last
                        else {
                            return """
                                /* #evaluationError: RoutineCall param \
                                \($0.payload.symbols.handles(.commaSeparated)) */
                                """
                        }
                        return "\(param.handle): \(value.handle)"
                    },
                    type: value.type,
                    payload: .init(
                        symbols: [
                            .instance(symbol),
                            value
                        ]
                    )
                )
            }
        }

        override func processSymbols() throws {
            for param in params {
                try param.payload?.symbols.assert(
                    .haveCommonType
                )

                try param.payload?.symbols.last?.assert(
                    .hasReturnValue
                )
            }
        }

        override func process() throws -> Symbol {
            guard let routine, let routineID = routine.id else {
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
                payload: .init(symbols: params),
                isFunctionCall: true
            )
        }
    }
}

extension Factories.RoutineCall {
    func findRoutine(_ id: String) throws -> Statement? {
        if let routine = Game.findRoutine(id) {
            return routine
        }

        if Game.findDefinition(id) != nil {
            let routine = try Game.Element(
                zil: zilName,
                tokens: tokens,
                with: &localVariables
            ).processDefinition()

            if case .statement(let routineStatement) = routine {
                return routineStatement
            }
        }

        return nil
    }
}

// MARK: - Errors

extension Factories.RoutineCall {
    enum Error: Swift.Error {
        case unknownRoutine(String, [Token])
        case unknownRoutineName([Symbol])
    }
}
