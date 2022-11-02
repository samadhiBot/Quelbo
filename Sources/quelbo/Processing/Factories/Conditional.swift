//
//  Conditional.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/22/22.
//

import Foundation

extension Factories {
    /// A symbol factory for a single conditional predicate and associated expressions within a
    /// Quelbo ``Condition``.
    class Conditional: Factory {
        var blockProcessor: BlockProcessor!
        var predicate: Symbol!

        override func processTokens() throws {
            var conditionTokens = tokens

            guard let predicateToken = conditionTokens.shift() else {
                throw Error.missingConditionPredicate
            }

            predicate = try symbolize(predicateToken)

            conditionTokens.insert(.list([]), at: 0)
            blockProcessor = try Factories.BlockProcessor(
                conditionTokens,
                with: &localVariables,
                mode: mode
            )
            blockProcessor.assert(implicitReturns: false)
        }

        override func processSymbols() throws {
            try? predicate.assert(
                .hasType(.bool)
            )
        }

        func ifStatement(for predicate: Symbol?) -> String {
            guard let predicate else { return "" }

            let predicateCode = {
                guard
                    predicate.type.dataType == .bool &&
                    predicate.type.isTableElement != true
                else {
                    return "_ = \(predicate.code)"
                }
                return predicate.code
            }()

            switch predicateCode {
            case "else", "t", "true":
                return ""
            default:
                return "if \(predicateCode) "
            }
        }

        override func process() throws -> Symbol {
            let ifStatement = ifStatement

            return .statement(
                code: {
                    return """
                        \(ifStatement($0.payload.predicate)){
                        \($0.payload.code.indented)
                        }
                        """
                },
                type: blockProcessor.payload.returnType ?? .void,
                payload: .init(
                    predicate: predicate,
                    symbols: blockProcessor.payload.symbols
                ),
                returnHandling: .suppress
            )
        }
    }
}

// MARK: - Errors

extension Factories.Conditional {
    enum Error: Swift.Error {
        case missingConditionPredicate
    }
}
