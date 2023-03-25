//
//  And.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [AND](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3utoxif)
    /// function.
    class And: Factory {
        override class var zilNames: [String] {
            ["AND"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(1))
            )

            try symbols.withNoTypeConfidence.assert(
                .haveType(.bool)
            )
        }

        var function: String {
            "and"
        }

        override func evaluate() throws -> Symbol {
            var elements = try symbols.nonCommentSymbols.map {
                guard
                    let code = $0.evaluation?.code,
                    let boolean = Bool(code)
                else {
                    throw Error.invalidMathEvaluationArgument($0)
                }
                return boolean
            }
            guard var result = elements.shift() else {
                throw Error.expectedAtLeastOneElement
            }
            while let element = elements.shift() {
                switch function {
                case "and": result = result && element
                case "or": result = result || element
                default: throw Error.invalidBooleanEvaluationFunction(function)
                }
            }
            return .literal(result)
        }

        override func process() throws -> Symbol {
            let function = function
            let operands = symbols

            print("▶️", operands.handles())
            return .statement(
                code: { _ in
                    ".\(function)(\(operands.handles(.commaSeparatedNoTrailingComma)))"
                },
                type: operands.map(\.type).max() ?? .bool
            )
        }
    }
}

// MARK: - Errors

extension Factories.And {
    enum Error: Swift.Error {
        case invalidMathEvaluationArgument(Symbol)
        case invalidBooleanEvaluationFunction(String)
        case expectedAtLeastOneElement
    }
}
