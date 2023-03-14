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
    class Pseudos: Factory {
        override class var factoryType: FactoryType {
            .property
        }

        override class var zilNames: [String] {
            ["PSEUDO"]
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
                    action: \(action.lowerCamelCase.quoted),
                    adjectives: [],
                    nouns: [\(noun.lowerCamelCase.quoted)]
                    """

                symbols.append(.statement(
                    code: { _ in
                        """
                        Thing(
                        \(code.indented)
                        )
                        """
                    },
                    type: .object
                ))
            }
        }

        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "things" },
                    type: .object.array
                )
            }

            let pseudos = symbols

            return .statement(
                id: "things",
                code: { _ in
                    "things: [\(pseudos.codeValues(.commaSeparated))]"
                },
                type: .object.array
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
