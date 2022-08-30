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
    var confidence: DataType.Confidence? { get }
    var isMutable: Bool? { get }
    var type: DataType? { get }
}

extension SymbolType {
    func assertHasCategory(_ assertionCategory: Category) throws {
        if let category = category, assertionCategory != category {
            throw Symbol.AssertionError.hasCategoryAssertionFailed(
                for: "\(Self.self)",
                asserted: assertionCategory,
                actual: category
            )
        }
    }

    func assertHasMutability(_ mutability: Bool) throws {
        guard let isMutable = isMutable else { return }

        guard mutability == isMutable else {
            throw Symbol.AssertionError.hasMutabilityAssertionFailed(
                for: "\(Self.self)",
                asserted: mutability,
                actual: isMutable
            )
        }
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
