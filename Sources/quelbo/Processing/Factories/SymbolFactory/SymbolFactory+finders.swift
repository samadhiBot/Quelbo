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
                id: .id(name),
                code: name.lowerCamelCase
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

    /// Attempts to find a known ``Symbol/DataType-swift.enum`` given a symbol identifier and
    /// factory parameters index.
    ///
    /// - Parameters:
    ///   - id: A symbol identifier.
    ///   - index: A factory parameters index.
    ///
    /// - Returns: A symbol data type if known, or `.unknown`.
    func findType(of id: Symbol.Identifier, at index: Int) throws -> Symbol.DataType {
        let expected = try Self.parameters.expectedType(at: index)
        let registered = types[id] ?? .unknown
        return [expected, registered].common ?? .unknown
    }
}

// MARK: - Errors

extension SymbolFactory {
    enum FindError: Swift.Error {
        case nameSymbolNotFound([Token])
        case parametersSymbolNotFound([Token])
        case conflictingTypes(
            id: Symbol.Identifier,
            expected: Symbol.DataType,
            registered: Symbol.DataType
        )
    }
}
