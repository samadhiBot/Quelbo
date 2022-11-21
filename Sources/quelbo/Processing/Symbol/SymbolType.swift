//
//  SymbolType.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import CustomDump
import Foundation

protocol SymbolType: Equatable, CustomDebugStringConvertible {
    var category: Category? { get }
    var code: String { get }
    var isMutable: Bool? { get }
    var type: TypeInfo { get }
}

// MARK: - Assertion helpers

extension SymbolType {
    func assertHasCategory(_ assertionCategory: Category) throws {
        if let category, assertionCategory != category {
            throw Symbol.AssertionError.hasCategoryAssertionFailed(
                for: "\(Self.self)",
                asserted: assertionCategory,
                actual: category
            )
        }
    }

    func assertHasMutability(_ mutability: Bool) throws {
        switch isMutable {
        case mutability, .none: return
        default:
            throw Symbol.AssertionError.hasMutabilityAssertionFailed(
                for: "\(Self.self)",
                asserted: mutability,
                actual: isMutable
            )
        }
    }
}

// MARK: - Computed properties

extension SymbolType {
    var typeDescription: String {
        type.description
    }
}

// MARK: - Conformances

extension SymbolType {
    var debugDescription: String {
        var description = ""
        customDump(self, to: &description)
        return description
    }
}
