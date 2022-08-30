//
//  Factory+finders.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension FactoryType {
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
    func findName(in tokens: inout [Token]) throws -> String {
        let original = tokens

        while !tokens.isEmpty {
            let token = tokens.shift()
            switch token {
            case .atom(let name): return name
            case .commented: continue
            default: throw FindError.unexpectedTokenWhileFindingName(original)
            }
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
//    func findParameters(
//        in tokens: inout [Token],
//        substituting: [Token] = []
//    ) throws -> [Symbol] {
//        let original = tokens
//        var substitutions = substituting
//        var context: Symbol.ParamContext = .normal
//
//        guard case .list(let params) = tokens.shift() else {
//            throw FindError.parametersNotFound(tokens)
//        }
//
//        return try params.compactMap { token in
//            switch token {
//            case .string("ARGS"):
//                context = .normal
//            case .string("AUX"), .string("EXTRA"):
//                context = .local
//            case .string("OPT"), .string("OPTIONAL"):
//                context = .optional
//            case .atom(let name):
//                if let substitution = substitutions.shift() {
//                    return .variable(id: substitution.value.lowerCamelCase)
//                } else {
//                    return .variable(id: name.lowerCamelCase)
//                }
//            }
//            return nil
//        }
//
////        throw FindError.parametersSymbolNotFound(original)
//    }

//    /// Searches the ``Factory/registry`` for a symbol whose `id` matches the one specified.
//    ///
//    /// - Parameter id: The symbol `id` to search for.
//    ///
//    /// - Returns: A symbol with the specified `id` if one has been registered.
//    func findRegistered(_ id: Symbol.Identifier?) -> Symbol? {
//        guard let id = id else { return nil }
//
//        return registry.first(where: { $0.id == id })
//    }
//
//    /// <#Description#>
//    /// - Parameter symbol: <#symbol description#>
//    /// - Returns: <#description#>
//    func upsert(_ symbol: Symbol) throws -> Symbol {
//        guard symbol.isIdentifiable else { return symbol }
//
//        guard symbol.category != .globals else { return Game.upsert(symbol) }
//
//        if let existing = registry.find(id: symbol.id) {
//            return existing.reconcile(with: symbol)
//        } else {
//            localVariables.append(symbol)
//            return symbol
//        }
//    }
}

// MARK: - Errors

extension FactoryType {
    enum FindError: Swift.Error {
//        case conflictingTypes(
//            id: Symbol.Identifier,
//            expected: DataType,
//            registered: DataType
//        )
        case nameSymbolNotFound([Token])
        case parametersNotFound([Token])
        case unexpectedTokenWhileFindingName([Token])
        case unexpectedTokenWhileFindingParameters([Token])
//        case valueSymbolNotFound([Token])
    }
}
