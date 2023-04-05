//
//  Arithmetic.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/18/23.
//

import Foundation

extension Factories {
    /// A symbol parent factory for Zil arithmetic functions.
    class Arithmetic: Factory {
        var operation: Operation {
            .add
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
            if elements.isEmpty && operation == .subtract {
                return .literal(-result)
            }
            while let element = elements.shift() {
                switch operation {
                case .add: result += element
                case .divide: result /= element
                case .modulo: result %= element
                case .multiply: result *= element
                case .subtract: result -= element
                }
            }
            return .literal(result)
        }

        override func process() throws -> Symbol {
            var arguments = symbols
            let firstArg = arguments.removeFirst()
            let function = operation

            return .statement(
                code: { _ in
                    """
                    \(firstArg.chainingID).\
                    \(function)\
                    (\(arguments.handles(.commaSeparatedNoTrailingComma)))
                    """
                },
                type: .int
            )
        }
    }
}

// MARK: - Factories.Arithmetic.Operation

extension Factories.Arithmetic {
    enum Operation: String {
        case add
        case divide
        case modulo
        case multiply
        case subtract
    }
}

// MARK: - Errors

extension Factories.Arithmetic {
    enum Error: Swift.Error {
        case invalidMathEvaluationArgument(Symbol)
        case expectedAtLeastOneElement
    }
}
