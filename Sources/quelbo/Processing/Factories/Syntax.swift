//
//  Syntax.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/5/22.
//

import Fizmo
import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [SYNONYM](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3sv78d1)
    /// function.
    class Syntax: Factory {
        override class var zilNames: [String] {
            ["SYNTAX"]
        }

        var verb: String = ""
        var definition: [String] = []

        override func processTokens() throws {
            var tokens = tokens
            guard case .atom(let verbZil) = tokens.shift() else {
                throw Error.missingSyntaxVerb(tokens)
            }
            self.verb = verbZil.lowerCamelCase
            definition.append("verb: \(verb.quoted)")

            if let directObject = try findObject(in: &tokens) {
                definition.append("directObject: \(directObject)")
            }
            if let indirectObject = try findObject(in: &tokens) {
                definition.append("indirectObject: \(indirectObject)")
            }

            guard case .atom("=") = tokens.shift() else {
                throw Error.missingSyntaxEqualsSign(tokens)
            }

            guard case .atom(let actionRoutine) = tokens.shift() else {
                throw Error.missingSyntaxActionRoutine(tokens)
            }
            definition.append("actionRoutine: \(actionRoutine.lowerCamelCase)")

            if case .atom(let preActionRoutine) = tokens.shift() {
                definition.append("preActionRoutine: \(preActionRoutine.lowerCamelCase)")
            }
        }

        override func process() throws -> Symbol {
            let definition = definition

            let symbol: Symbol = .statement(
                id: verb,
                code: { _ in
                    "Syntax(\(definition.values(.commaSeparatedNoTrailingComma)))"
                },
                type: .void,
                confidence: .certain,
                category: .syntax
            )

            try! Game.commit(symbol)

            return symbol
        }
    }
}

extension Factories.Syntax {
    func findObject(in tokens: inout [Token]) throws -> String? {
        var definition: [String] = []
        if case .atom("=") = tokens.first {
            return nil
        }

        switch tokens.first {
        case .atom("="):
            return nil
        case .atom("OBJECT"):
            break
        case .atom(let preposition):
            definition.append("preposition: \(preposition.lowerCamelCase.quoted)")
            tokens.removeFirst()
            guard case .atom("OBJECT") = tokens.first else {
                throw Error.missingSyntaxObjectAfterPreposition(tokens)
            }
        default:
            throw Error.invalidSyntaxParameter(tokens)
        }
        tokens.removeFirst()

        while case .list(var listTokens) = tokens.first {
            tokens.removeFirst()
            if case .atom("FIND") = listTokens.first {
                listTokens.removeFirst()
                guard case .atom(let zil) = listTokens.shift() else {
                    throw Error.missingSyntaxAtomAfterFind(listTokens)
                }
                let flag = Flag.find(zil.lowerCamelCase)
                definition.append("where: \(flag.id)")
                guard listTokens.isEmpty else {
                    throw Error.unconsumedSyntaxTokensAfterFind(listTokens)
                }
            } else {
                let searchFlags = try listTokens
                    .map {
                        guard
                            case .atom(let flag) = listTokens.shift(),
                            let searchFlag = Syntax.SearchFlag(rawValue: flag)
                        else {
                            throw Error.invalidSyntaxSearchFlag($0)
                        }
                        return searchFlag.case
                    }
                    .sorted()
                    .joined(separator: ", ")
                definition.append("search: [\(searchFlags)]")
            }
        }

        guard !definition.isEmpty else {
            return "Syntax.Object()"
        }

        return """
            Syntax.Object(
            \(definition.joined(separator: ",\n").indented)
            )
            """
    }
}

// MARK: - Errors

extension Factories.Syntax {
    enum Error: Swift.Error {
        case invalidSyntaxParameter([Token])
        case invalidSyntaxSearchFlag(Token)
        case missingSyntaxActionRoutine([Token])
        case missingSyntaxAtomAfterFind([Token])
        case missingSyntaxEqualsSign([Token])
        case missingSyntaxObjectAfterPreposition([Token])
        case missingSyntaxVerb([Token])
        case unconsumedSyntaxTokensAfterFind([Token])
    }
}
