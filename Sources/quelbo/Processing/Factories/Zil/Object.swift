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
    class Object: ZilFactory {
        override class var zilNames: [String] {
            ["OBJECT"]
        }

        override class var returnType: Symbol.DataType {
            .object
        }

        var nameSymbol: Symbol!
        var directionSymbols: [Symbol] = []
        var propertySymbols: [Symbol] = []

        var category: Symbol.Category {
            .objects
        }

        var typeName: String {
            "Object"
        }

        override func processTokens() throws {
            var tokens = tokens

            self.nameSymbol = try findNameSymbol(in: &tokens)
            self.propertySymbols = try findPropertySymbols(in: &tokens)
            if !directionSymbols.isEmpty {
                self.propertySymbols.append(Symbol(
                    id: .id("directions"),
                    code: """
                        directions: [\(directionSymbols.codeValues(.commaSeparated))]
                        """,
                    type: .array(.direction),
                    children: directionSymbols
                ))
            }
        }

        override func process() throws -> Symbol {
            let symbol = Symbol(
                id: nameSymbol.id,
                code: """
                    /// The `\(nameSymbol.id)` (\(nameSymbol.zilName)) \(typeName.lowercased()).
                    var \(nameSymbol.id) = \(typeName)(
                    \(propertySymbols.sorted.codeValues(.commaLineBreakSeparated))
                    )
                    """,
                type: .object,
                category: category,
                children: propertySymbols
            )
            try Game.commit(symbol)
            return symbol
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
                guard case .atom(let zil) = tokens.shift() else {
                    throw Error.invalidObjectListProperty(token)
                }
                if let propertyFactory = try Game.zilPropertyFactories.find(zil) {
                    do {
                        let factory = try propertyFactory.init(tokens, with: registry)
                        return try factory.process()
                    } catch {
                        guard zil == "IN" else { throw error }
                    }
                }
                if isDirection(zil) {
                    let factory = try Factories.MoveDirection(listTokens, with: registry)
                    directionSymbols.append(try factory.process())
                    return nil
                }
                let factory = try Factories.Other.init(listTokens, with: registry)
                return try factory.process()
            default:
                throw Error.invalidObjectProperty(token)
            }
        }
    }

    func isDirection(_ zil: String) -> Bool {
        if let _ = try? Game.find(
            .id(zil.lowerCamelCase),
            category: .properties
        ) {
            return true
        }
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

