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
        var propertySymbols: [Symbol] = []

        override func processTokens() throws {
            var tokens = tokens

            self.nameSymbol = try findNameSymbol(in: &tokens)
            self.propertySymbols = try findPropertySymbols(in: &tokens)
        }

        override func process() throws -> Symbol {
            print("  + Processing object \(nameSymbol.code)")

            let symbol = Symbol(
                id: nameSymbol.code,
                code: """
                    /// The `\(nameSymbol.code)` (\(nameSymbol.id)) object.
                    var \(nameSymbol.code) = Object(
                    \(propertySymbols.codeValues(separator: ",", lineBreaks: 1, sorted: true).indented)
                    )
                    """,
                type: .object,
                category: .objects,
                children: propertySymbols
            )
            try Game.commit(symbol)
            return symbol
        }

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
                        if let factory = try Game.zilPropertyFactories.find(zil)?.init(tokens) {
                            return try factory.process()
                        }
                        let factory = try Factories.Other.init(listTokens)
                        return try factory.process()
                    default:
                        throw FactoryError.invalidProperty(token)
                }
            }
        }
    }
}
