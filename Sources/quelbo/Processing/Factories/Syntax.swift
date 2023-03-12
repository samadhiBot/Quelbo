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

        var definition: [String] = []

        var routines: [Symbol] = []

        override func processTokens() throws {
            var tokens = tokens
            guard case .atom(let verb) = tokens.shift() else {
                throw Error.missingSyntaxVerb(tokens)
            }
            definition.append("verb: \(verb.lowerCamelCase.quoted)")

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
            let action = actionRoutine.lowerCamelCase
            definition.append("action: \(action.quoted)")

            if case .atom(let preActionRoutine) = tokens.shift() {
                let preAction = preActionRoutine.lowerCamelCase
                definition.append("preAction: \(preAction.quoted)")
                routines.append(.verb(preAction))
            }

            routines.append(.verb(action))
        }

        override func process() throws -> Symbol {
            let definition = definition

            return .statement(
                id: identifier,
                code: { _ in
                    "Syntax(\(definition.values(.commaSeparatedNoTrailingComma)))"
                },
                type: .void,
                payload: .init(symbols: routines),
                category: .syntax,
                isCommittable: true
            )
        }
    }
}

extension Factories.Syntax {
    var identifier: String {
        var elements: [String] = []
        for token in tokens {
            guard case .atom(let string) = token else { continue }
            if string == "=" { break }
            elements.append(string)
        }
        return elements.joined(separator: "_").lowerCamelCase
    }

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
                let flag = Flag.findOrCreate(zil.lowerCamelCase)
                definition.append("where: \(flag.id.rawValue.quoted)")
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
