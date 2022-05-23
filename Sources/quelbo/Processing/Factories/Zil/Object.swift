//
//  Object.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/12/22.
//

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
                    id: "directions",
                    code: """
                        directions: [\(directionSymbols.codeValues(.commaSeparated))]
                        """,
                    type: .array(.direction),
                    children: directionSymbols
                ))
            }
        }

        override func process() throws -> Symbol {
            print("  + Processing object \(nameSymbol.code)")

            let symbol = Symbol(
                id: nameSymbol.code,
                code: """
                    /// The `\(nameSymbol.code)` (\(nameSymbol.id)) \(typeName.lowercased()).
                    var \(nameSymbol.code) = \(typeName)(
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
                    throw FactoryError.invalidProperty(token)
                }
                if let propertyFactory = try Game.zilPropertyFactories.find(zil) {
                    do {
                        let factory = try propertyFactory.init(tokens)
                        return try factory.process()
                    } catch {
                        guard zil == "IN" else { throw error }
                    }
                }
                if let moveFactory = Factories.MoveDirection.find(zil) {
                    let factory = try moveFactory.init(listTokens)
                    directionSymbols.append(try factory.process())
                    return nil
                }
                let factory = try Factories.Other.init(listTokens)
                return try factory.process()
            default:
                throw FactoryError.invalidProperty(token)
            }
        }
    }
}
