//
//  Condition.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [COND](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.u8tczi)
    /// function.
    class Condition: Factory {
        override class var zilNames: [String] {
            ["COND"]
        }

        var conditionalFactory: Factory.Type {
            Factories.Conditional.self
        }

        override func processTokens() throws {
            for token in tokens {
                switch token {
                case .commented: continue
                case .list(let conditionTokens):
                    symbols.append(
                        try conditionalFactory.init(
                            conditionTokens,
                            with: &localVariables,
                            mode: mode
                        ).process()
                    )
                default:
                    throw Error.unexpectedConditionToken(token)
                }
            }
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.atLeast(1)),
                .haveCommonType
            ])
        }

        override func process() throws -> Symbol {
            let conditions = symbols
            let type = conditions.returnType() ?? .void

            return .statement(
                code: { _ in
                    conditions
                        .map(\.handle)
                        .values(.separator(" else "))
                },
                type: type,
                children: conditions,
                returnHandling: .suppress
            )
        }
    }
}

// MARK: - Errors

extension Factories.Condition {
    enum Error: Swift.Error {
        case unexpectedConditionToken(Token)
    }
}
