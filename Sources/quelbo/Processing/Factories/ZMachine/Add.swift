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
    class Add: ZMachineFactory {
        override class var zilNames: [String] {
            ["+", "ADD"]
        }

        override class var parameters: Parameters {
            .twoOrMore(.int)
        }

        override class var returnType: Symbol.DataType {
            .int
        }

        var function: String {
            "add"
        }

        override func eval() throws -> Token {
            let result = try tokens.reduce(into: 0) { sum, token in
                switch token {
                case .decimal(let value):
                    sum += value
                default:
                    throw FactoryError.unimplemented(self)
                }
            }
            return .decimal(result)
        }

        override func process() throws -> Symbol {
            guard let first = symbols.shift() else {
                throw Error.missingInitialArithmaticValue(tokens)
            }

            let code: String
            let allSymbols: [Symbol]

            if first.isLiteral {
                allSymbols = [first] + symbols
                code = ".\(function)(\(allSymbols.codeValues(.commaSeparated)))"
            } else {
                allSymbols = [first.with(meta: [.mutating(true)])] + symbols
                code = "\(first.code).\(function)(\(symbols.codeValues(.commaSeparated)))"
            }

            return Symbol(code, type: .int, children: allSymbols)
        }
    }
}

// MARK: - Errors

extension Factories.Add {
    enum Error: Swift.Error {
        case missingInitialArithmaticValue([Token])
    }
}
