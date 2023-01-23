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
        override class var factoryType: Factories.FactoryType {
            .zCode
        }

        override class var zilNames: [String] {
            ["COND"]
        }

        var conditionalFactory: Factory.Type {
            Factories.Conditional.self
        }

        override func processTokens() throws {
            for token in tokens {
                switch token {
                case .commented:
                    continue
                case .eval:
                    symbols.append(
                        try symbolizeEval(token)
                    )
                case .list(let conditionTokens):
                    do {
                        let conditional = try processConditional(conditionTokens)
                        switch mode {
                        case .evaluate:
                            if conditional != .false {
                                symbols.append(conditional)
                                return
                            }
                        case .process:
                            symbols.append(conditional)
                        }
                    } catch SymbolizationError.unknownLocal(let zil) {
                        symbols.append(.statement(
                            code: { _ in
                                "if false /* Conditional failed to parse: \(zil) */"
                            },
                            type: .comment
                        ))
                    }
                default:
                    throw Error.unexpectedConditionToken(token)
                }
            }
        }

        func processConditional(
            _ conditionTokens: [Token],
            mode factoryMode: FactoryMode? = nil
        ) throws -> Symbol {
            if conditionTokens == [.form([.atom("RFALSE")])] {
                return .false
            }

            let conditional = try conditionalFactory.init(
                conditionTokens,
                with: &localVariables,
                mode: factoryMode ?? mode
            ).processOrEvaluate()

            if let definition = conditional.definition,
               case .list(let tokens) = definition.tokens.first
            {
                let processed = try processConditional(tokens, mode: .process)
                return processed
            }
            return conditional
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCommonType
            )
        }

        override func evaluate() throws -> Symbol {
            guard
                !symbols.isEmpty,
                let symbol = symbols.first(where: { $0 != .false })
            else {
                return .emptyStatement
            }

            if case .definition(let definition) = symbol,
               let definitionToken = definition.tokens.first
            {
                return try symbolize(definitionToken, mode: .process)
            }

            return symbol
        }

        override func process() throws -> Symbol {
            let conditionals = symbols
            let returnType = symbols
                .returningSymbols
                .returnType

            return .statement(
                code: {
                    let conditional = $0.payload.symbols
                        .compactMap {
                            let code = $0.code
                            return code.isEmpty ? nil : code
                        }
                        .values(.separator(" else "))

                    if $0.payload.returnHandling == .forcedPassthrough {
                        return """
                            {
                            \(conditional.indented)
                            }()
                            """
                    }
                    return conditional
                },
                type: returnType ?? .void,
                payload: .init(
                    returnHandling: .passthrough,
                    symbols: conditionals
                ),
                returnHandling: .passthrough
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
