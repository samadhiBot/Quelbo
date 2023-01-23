//
//  ConditionMDL.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/13/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the MDL
    /// [COND](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.xlwhh4mde7i8)
    /// function.
    class ConditionMDL: Condition {
        override class var factoryType: Factories.FactoryType {
            .mdl
        }

        override class var zilNames: [String] {
            ["COND"]
        }

        override func processTokens() throws {
            for token in tokens {
                switch token {
                case .commented:
                    continue
                case .list(let conditionTokens):
                    let conditional = try processConditional(conditionTokens, mode: .evaluate)
                    if conditional != .false {
                        symbols.append(conditional)
                    }
                default:
                    throw Error.unexpectedConditionToken(token)
                }
            }
        }

        override func evaluate() throws -> Symbol {
            guard
                !symbols.isEmpty,
                let symbol = symbols.first(where: { $0 != .false }),
                case .definition(let definition) = symbol
            else {
                return .emptyStatement
            }

            return try symbolizeForm(
                definition.tokens,
                mode: .process,
                type: .mdl
            )
        }

        override func processOrEvaluate() throws -> Symbol {
            try evaluate()
        }
    }
}
