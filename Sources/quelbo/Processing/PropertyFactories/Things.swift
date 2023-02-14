//
//  Things.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `THINGS` / `PSEUDO` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Things: Factory {
        override class var zilNames: [String] {
            ["THINGS"]
        }

        override func processTokens() throws {
            var tokens = tokens
            while !tokens.isEmpty {
                guard
                    let adjectiveToken = tokens.shift(),
                    let nounToken = tokens.shift(),
                    let actionToken = tokens.shift()
                else {
                    throw Error.missingThingParameters(self.tokens)
                }

                var adjectives: [String] = []
                switch adjectiveToken {
                    case .atom(let value):
                        adjectives = [value.lowerCamelCase]
                    case .bool(false):
                        adjectives = []
                    case .list(let values):
                        adjectives = try values.map {
                            guard case .atom(let value) = $0 else {
                                throw Error.invalidThingAdjective(adjectiveToken)
                            }
                            return value.lowerCamelCase
                        }
                    default:
                        throw Error.invalidThingAdjective(adjectiveToken)
                }

                var nouns: [String] = []
                switch nounToken {
                    case .atom(let value):
                        nouns = [value.lowerCamelCase]
                    case .list(let values):
                        nouns = try values.map {
                            guard case .atom(let value) = $0 else {
                                throw Error.invalidThingNoun(nounToken)
                            }
                            return value.lowerCamelCase
                        }
                    default:
                        throw Error.invalidThingNoun(nounToken)
                }

                var code: String
                switch actionToken {
                    case .atom(let actionRoutine):
                        code = """
                            action: \(actionRoutine.lowerCamelCase),
                            adjectives: \(adjectives),
                            nouns: \(nouns)
                            """
                    case .string(let text):
                        code = """
                            adjectives: \(adjectives),
                            nouns: \(nouns),
                            text: \(text.quoted)
                            """
                    default:
                        throw Error.invalidThingAction(actionToken)
                }

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

            let pseudos = symbols.sorted

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

extension Factories.Things {
    enum Error: Swift.Error {
        case invalidThingAction(Token)
        case invalidThingAdjective(Token)
        case invalidThingNoun(Token)
        case missingThingParameters([Token])
    }
}
