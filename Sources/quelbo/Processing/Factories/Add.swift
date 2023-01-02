//
//  Add.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ADD](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2i9l8ns)
    /// function.
    class Add: Factory {
        override class var zilNames: [String] {
            ["+", "ADD"]
        }

        var function: String {
            "add"
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(2)),
                .haveType(.int)
            )
        }

        override func evaluate() throws -> Symbol {
            var elements = try symbols.nonCommentSymbols.map {
                guard
                    let code = $0.evaluation?.code,
                    let integer = Int(code)
                else {
                    throw Error.invalidMathEvaluationArgument($0)
                }
                return integer
            }
            guard var result = elements.shift() else {
                throw Error.expectedAtLeastOneElement
            }
            if elements.isEmpty && function == "subtract" {
                return .literal(-result)
            }
            while let element = elements.shift() {
                switch function {
                case "add": result += element
                case "divide": result /= element
                case "multiply": result *= element
                case "subtract": result -= element
                default: throw Error.invalidMathEvaluationFunction(function)
                }
            }
            return .literal(result)
        }

        override func process() throws -> Symbol {
            let arguments = symbols
            let function = function

            return .statement(
                code: { _ in
                    ".\(function)(\(arguments.codeValues(.commaSeparatedNoTrailingComma)))"
                },
                type: .int
            )
        }
    }
}

// MARK: - Errors

extension Factories.Add {
    enum Error: Swift.Error {
        case invalidMathEvaluationArgument(Symbol)
        case invalidMathEvaluationFunction(String)
        case expectedAtLeastOneElement
    }
}
