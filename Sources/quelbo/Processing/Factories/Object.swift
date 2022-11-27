//
//  Object.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/12/22.
//

import Fizmo
import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// function.
    class Object: Factory {
        override class var zilNames: [String] {
            ["OBJECT"]
        }

        var directionSymbols: [Symbol] = []

        var zilName: String!

        var category: Category {
            .objects
        }

        var typeName: String {
            "Object"
        }

        override func processTokens() throws {
            var tokens = tokens

            self.zilName = try findName(in: &tokens)
            self.symbols = try findPropertySymbols(in: &tokens)
        }

        override func processSymbols() throws {
            guard !directionSymbols.isEmpty else { return }

            symbols.append(
                .statement(
                    code: {
                        let directions = $0.payload.symbols.codeValues(.commaSeparated)

                        return "directions: [\(directions)]"
                    },
                    type: .object.array,
                    payload: .init(
                        symbols: directionSymbols
                    )
                )
            )
        }

        override func process() throws -> Symbol {
            let name = zilName.lowerCamelCase
            let objectType = typeName
            let properties = symbols.sorted
            let zilName = zilName!

            return .statement(
                id: name,
                code: { _ in
                    """
                    /// The `\(name)` (\(zilName)) \(objectType.lowercased()).
                    var \(name) = \(objectType)(
                    \(properties.codeValues(.commaLineBreakSeparated))
                    )
                    """
                },
                type: .object,
                payload: .init(
                    symbols: properties
                ),
                category: category,
                isCommittable: true
            )
        }
    }
}

extension Factories.Object {
    /// Scans through a ``Token`` array until it finds a parameter list, then returns a translated
    /// ``Symbol`` array.
    ///
    /// The `Token` array is mutated in the course of the search, removing any elements up to and
    /// including the target list.
    ///
    /// - Parameter tokens: A `Token` array to search.
    ///
    /// - Returns: An array of `Symbol` translations of the list tokens.
    ///
    /// - Throws: When no list is found, or token symbolization fails.
    func findPropertySymbols(in tokens: inout [Token]) throws -> [Symbol] {
        try tokens.compactMap { token in
            switch token {
            case .commented:
                return nil
            case .list(let listTokens):
                var tokens = listTokens
                let zilName = try findName(in: &tokens)

                if let propertyFactory = Game.findFactory(zilName, type: .property) {
                    do {
                        let factory = try propertyFactory.init(tokens, with: &localVariables)
                        return try factory.process()
                    } catch {
                        guard zilName == "IN" else { throw error }
                    }
                }
                if isDirection(zilName) {
                    let factory = try Factories.MoveDirection(listTokens, with: &localVariables)
                    directionSymbols.append(try factory.process())
                    return nil
                }
                let factory = try Factories.Other(listTokens, with: &localVariables)
                return try factory.process()
            default:
                throw Error.invalidObjectProperty(token)
            }
        }
    }

    func isDirection(_ zil: String) -> Bool {
        if Game.properties.find(zil.lowerCamelCase) != nil { return true }

        return Direction.find(zil) != nil
    }
}

// MARK: - Errors

extension Factories.Object {
    enum Error: Swift.Error {
        case invalidObjectListProperty(Token)
        case invalidObjectProperty(Token)
    }
}
