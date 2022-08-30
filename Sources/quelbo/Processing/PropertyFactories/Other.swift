//
//  Other.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for any unhandled properties of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Other: PropertyFactory {
        var name: String!

        override func processTokens() throws {
            var tokens = tokens

            self.name = try findName(in: &tokens)
            self.symbols = try symbolize(tokens)
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCommonType)
        }

        override func process() throws -> Symbol {
            let code: String
            let name = name!.lowerCamelCase
            let type = symbols[0].type

            switch symbols.count {
            case 0: throw Error.missingOtherParameters(tokens)
            case 1: code = symbols[0].code
            default: code = "[\(symbols.codeValues(.commaSeparated))]"
            }

            return .statement(
                id: name,
                code: { _ in
                    "\(name): \(code)"
                },
                type: type,
                confidence: .certain
            )
        }
    }
}

// MARK: - Errors

extension Factories.Other {
    enum Error: Swift.Error {
        case missingOtherParameters([Token])
    }
}
