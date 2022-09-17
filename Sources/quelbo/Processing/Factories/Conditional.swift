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

        func ifStatement(for predicateCode: String) -> String {
            switch predicateCode {
            case "else", "t", "true": return ""
            default: return "if \(predicateCode) "
            }
        }

        override func processTokens() throws {
            var conditionTokens = tokens

            guard let predicateToken = conditionTokens.shift() else {
                throw Error.missingConditionPredicate
            }

            predicate = try symbolize(predicateToken)

            conditionTokens.insert(.list([]), at: 0)
            blockProcessor = try Factories.BlockProcessor(
                conditionTokens,
                with: &localVariables
            )
            blockProcessor.assert(implicitReturns: false)
        }

        override func process() throws -> Symbol {
            let ifStatement = ifStatement(for: predicate.code)
            let pro = blockProcessor!
            let type = try pro.returnType() ?? .void

            return .statement(
                code: { _ in
                    """
                    \(ifStatement){
                    \(pro.code.indented)
                    }
                    """
                },
                type: type,
                children: pro.symbols
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
