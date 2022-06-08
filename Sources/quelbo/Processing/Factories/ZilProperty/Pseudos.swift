//
//  Pseudos.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `THINGS` / `PSEUDO` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Pseudos: ZilPropertyFactory {
        override class var zilNames: [String] {
            ["PSEUDO"]
        }

        override class var returnType: Symbol.DataType {
            .array(.thing)
        }

        override func processTokens() throws {
            var tokens = tokens
            while !tokens.isEmpty {
                guard
                    case .string(let noun) = tokens.shift(),
                    case .atom(let action) = tokens.shift()
                else {
                    throw Error.invalidPseudoParameters(self.tokens)
                }

                let code = """
                    adjectives: [],
                    nouns: [\(noun.lowerCamelCase.quoted)],
                    action: \(action.lowerCamelCase)
                    """

                symbols.append(Symbol(
                    id: "thing",
                    code: """
                        Thing(
                        \(code.indented)
                        )
                        """,
                    type: .thing
                ))
            }
        }

        override func process() throws -> Symbol {
            Symbol(
                id: "things",
                code: "things: [\(symbols.codeValues(.commaSeparated))]",
                type: Self.returnType,
                children: symbols
            )
        }
    }
}

// MARK: - Errors

extension Factories.Pseudos {
    enum Error: Swift.Error {
        case invalidPseudoParameters([Token])
    }
}
