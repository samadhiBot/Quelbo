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
    class Things: ZilPropertyFactory {
        override class var zilNames: [String] {
            ["THINGS"]
        }

        override class var returnType: Symbol.DataType {
            .array(.thing)
        }

        override func processTokens() throws {
            var tokens = tokens
            while !tokens.isEmpty {
                guard
                    let adjectiveToken = tokens.shift(),
                    let nounToken = tokens.shift(),
                    let actionToken = tokens.shift()
                else {
                    throw FactoryError.missingParameters(self.tokens)
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
                                throw FactoryError.invalidProperty(adjectiveToken)
                            }
                            return value.lowerCamelCase
                        }
                    default:
                        throw FactoryError.invalidProperty(adjectiveToken)
                }

                var nouns: [String] = []
                switch nounToken {
                    case .atom(let value):
                        nouns = [value.lowerCamelCase]
                    case .list(let values):
                        nouns = try values.map {
                            guard case .atom(let value) = $0 else {
                                throw FactoryError.invalidProperty(nounToken)
                            }
                            return value.lowerCamelCase
                        }
                    default:
                        throw FactoryError.invalidProperty(nounToken)
                }

                var thingCode: String
                switch actionToken {
                    case .atom(let actionRoutine):
                        thingCode = """
                            adjectives: \(adjectives),
                            nouns: \(nouns),
                            action: \(actionRoutine.lowerCamelCase)
                            """
                    case .string(let text):
                        thingCode = """
                            adjectives: \(adjectives),
                            nouns: \(nouns),
                            text: \(text.quoted)
                            """
                    default:
                        throw FactoryError.invalidProperty(actionToken)
                }

                symbols.append(Symbol(
                    id: "thing",
                    code: """
                        Thing(
                        \(thingCode.indented)
                        )
                        """,
                    type: .thing
                ))
            }
        }

        // struct Thing: Equatable {
        //     let adjectives: [String]
        //     let nouns: [String]
        //     let action: Routine?
        //     let text: String?
        // }

        override func process() throws -> Symbol {
            Symbol(
                id: "things",
                code: "things: \(symbols.code)",
                type: Self.returnType,
                children: symbols
            )
        }
    }
}
