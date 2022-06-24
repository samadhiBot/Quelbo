//
//  SymbolFactory+finders.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension SymbolFactory {
    /// Scans through a ``Token`` array until it finds an atom, then returns a ``Symbol``
    /// representation, where `id` contains a Swift name translation, and `meta` contains a
    /// ``Symbol/MetaData/zilName(_:)`` case with the original Zil name.
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
                id: .id(name.lowerCamelCase),
                meta: [.zilName(name)]
            )
        }

        throw FindError.nameSymbolNotFound(original)
    }

    /// Scans through a ``Token`` array until it finds a parameter list, then returns a translated
    /// ``Symbol`` array.
    ///
    /// The `Token` array is mutated in the course of the search, removing any elements up to and
    /// including the target list.
    ///
    /// Any token specified in `substituting` is substituted in for the corresponding element in
    /// the `tokens` array. This applies when processing unevaluated
    /// ``Symbol/Category-swift.enum/definitions``.
    ///
    /// - Parameters:
    ///   - tokens: A `Token` array to search.
    ///   - substituting: And optional `Token` array to substitute for the found parameters.
    ///
    /// - Returns: An array of `Symbol` translations of the list tokens.
    ///
    /// - Throws: When no list is found, or token symbolization fails.
    func findParameterSymbols(
        in tokens: inout [Token],
        substituting: [Token] = []
    ) throws -> [Symbol] {
        let original = tokens
        var substitutions = substituting

        while !tokens.isEmpty {
            guard case .list(let params) = tokens.shift() else {
                throw FindError.parametersSymbolNotFound(tokens)
            }
            return try params.map { token in
                switch token {
                case .string("ARGS"):
                    return Symbol(id: "<Arguments>")
                case .string("AUX"), .string("EXTRA"):
                    return Symbol(id: "<Locals>")
                case .string("OPT"), .string("OPTIONAL"):
                    return Symbol(id: "<Optionals>")
                default:
                    if let substitution = substitutions.shift() {
                        return try symbolize(substitution)
                    } else {
                        return try symbolize(token)
                    }
                }
            }
        }

        throw FindError.parametersSymbolNotFound(original)
    }
}

// MARK: - Errors

extension SymbolFactory {
    enum FindError: Swift.Error {
        case conflictingTypes(
            id: Symbol.Identifier,
            expected: Symbol.DataType,
            registered: Symbol.DataType
        )
        case nameSymbolNotFound([Token])
        case parametersSymbolNotFound([Token])
        case valueSymbolNotFound([Token])
    }
}
