//
//  SymbolFactory+finders.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension SymbolFactory {
    /// Scans through a ``Token`` array until it finds an atom, then returns a special ``Symbol``
    /// representation, where `id` contains the original Zil name, and `code` contains its Swift
    /// translation.
    ///
    /// The `Token` array is mutated in the course of the search, removing any elements up to and
    /// including the target atom.
    ///
    /// - Parameter tokens: A `Token` array to search.
    ///
    /// - Returns: A `Symbol` translation of the found atom.
    ///
    /// - Throws: When no atom is found.
    func findNameSymbol(in tokens: inout [Token]) throws -> Symbol {
        let original = tokens
        while !tokens.isEmpty {
            guard case .atom(let name) = tokens.shift() else {
                continue
            }
            return Symbol(
                id: .init(stringLiteral: name),
                code: name.lowerCamelCase
            )
        }
        throw FactoryError.missingName(original)
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
    func findParameterSymbols(in tokens: inout [Token]) throws -> [Symbol] {
        let original = tokens
        while !tokens.isEmpty {
            guard case .list(let params) = tokens.shift() else {
                throw FactoryError.missingParameters(tokens)
            }
            return try params.map { token in
                switch token {
                case .string("ARGS"):
                    return Symbol("<Arguments>")
                case .string("AUX"), .string("EXTRA"):
                    return Symbol("<Locals>")
                case .string("OPT"), .string("OPTIONAL"):
                    return Symbol("<Optionals>")
                default:
                    return try symbolize(token)
                }
            }
        }
        throw FactoryError.missingParameters(original)
    }
}
