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

        override func process() throws -> Symbol {
            let ifStatement = ifStatement(for: predicateCode())
            let pro = blockProcessor!
            let type = pro.returnType() ?? .void

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

        func ifStatement(for predicateCode: String) -> String {
            switch predicateCode {
            case "else", "t", "true": return ""
            default: return "if \(predicateCode) "
            }
        }

        func predicateCode() -> String {
            if predicate.type.dataType == .bool {
                return predicate.code
            }
            return "_ = \(predicate.code)"
        }
    }
}

// MARK: - Errors

extension Factories.Conditional {
    enum Error: Swift.Error {
        case missingConditionPredicate
    }
}
