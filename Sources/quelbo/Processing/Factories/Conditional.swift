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
        var blockProcessor: BlockProcessor?
        var predicate: Symbol?

        override func processTokens() throws {
            var conditionTokens = tokens

            guard let predicateToken = conditionTokens.shift() else {
                throw Error.missingConditionPredicate
            }

            self.predicate = try {
                if predicateToken == .atom("T") {
                    return .true
                }
                return try symbolize(predicateToken, mode: mode)
            }()

            switch mode {
            case .evaluate:
                guard predicate == .true else { return }
                let evaluated = try symbolize(conditionTokens, mode: mode)
                if evaluated == [.true] {
                    symbols = [.emptyStatement]
                } else {
                    symbols = evaluated
                }

            case .process:
                conditionTokens.insert(.list([]), at: 0)
                self.blockProcessor = try Factories.BlockProcessor(
                    conditionTokens,
                    with: &localVariables,
                    mode: mode
                )
            }
        }

        override func processSymbols() throws {
            try? predicate?.assert(
                .hasType(.bool)
            )
        }

        func ifStatement(for predicate: Symbol?) -> String {
            guard let predicate else { return "" }

            let predicateCode = {
                if predicate.type.dataType == .bool && predicate.type.isTableElement != true {
                    return predicate.handle
                }
                if !predicate.code.contains(/\W/) {
                    return "let \(predicate.handle)"
                }
                return "_ = \(predicate.handle)"
            }()

            switch predicateCode {
            case "else", "t", "true":
                return ""
            default:
                return "if \(predicateCode) "
            }
        }

        override func evaluate() throws -> Symbol {
            guard
                predicate?.evaluation == .true,
                let definition = symbols.first
            else { return .false }

            return definition
        }

        override func process() throws -> Symbol {
            let ifStatement = ifStatement

            return .statement(
                code: { statement in
                    let code = {
                        let code = statement.payload.code
                        return code.isEmpty ? "// do nothing" : code
                    }()
                    
                    return """
                        \(ifStatement(statement.payload.predicate)){
                        \(code.indented)
                        }
                        """
                },
                type: blockProcessor?.payload.returnType ?? .void,
                payload: .init(
                    predicate: predicate,
                    symbols: blockProcessor?.payload.symbols ?? []
                ),
                returnHandling: .suppressedPassthrough
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
