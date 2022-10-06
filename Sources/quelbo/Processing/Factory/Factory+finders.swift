//
//  Factory+finders.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension Factory {
    /// Scans a ``Token`` array for an atom containing a Zil name, which it returns.
    ///
    /// The `Token` array is mutated in the course of the search, removing any comments, up to and
    /// including the target atom.
    ///
    /// - Parameter tokens: A `Token` array to search.
    ///
    /// - Returns: A `String` containing the name from the found atom.
    ///
    /// - Throws: When no atom is found, or any non-comment token appears before finding an atom.
    func findName(in tokens: inout [Token]) throws -> String {
        let original = tokens

        while !tokens.isEmpty {
            let token = tokens.shift()
            switch token {
            case .atom(let name):
                return name
            case .commented:
                continue
            default:
                throw FindError.unexpectedTokenWhileFindingName(original)
            }
        }

        throw FindError.nameSymbolNotFound(original)
    }
}

// MARK: - Errors

extension Factory {
    enum FindError: Swift.Error {
        case nameSymbolNotFound([Token])
        case unexpectedTokenWhileFindingName([Token])
    }
}
