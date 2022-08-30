//
//  Symbol+Assertions.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/12/22.
//

import Foundation

enum SymbolElementAssertion {
    case hasCategory(Category)
    case hasMutability(Bool)
    case hasReturnValue
    case hasSameCategory(as: Symbol)
    case hasSameType(as: Symbol)
    case hasType(DataType)
    case hasTypeIn([DataType])
    case isImmutable
    case isMutable
    case isVariable
}

enum SymbolCollectionAssertion {
    case areVariables
    case haveCommonType
    case haveCount(SymbolCollectionCount)
    case haveSameType(as: Symbol)
    case haveType(DataType)
    case haveTypeIn([DataType])
}

enum SymbolCollectionCount {
    case atLeast(Int)
    case between(ClosedRange<Int>)
    case exactly(Int)
}

extension Symbol {
    func assert(_ assertion: SymbolElementAssertion) throws {
        switch assertion {
        case .hasCategory(let category):
            try assertHasCategory(category)
        case .hasMutability(let mutability):
            try assertHasMutability(mutability)
        case .hasReturnValue:
            try assertHasReturnValue()
        case .hasSameCategory(as: let other):
            if let otherCategory = other.category { try assertHasCategory(otherCategory) }
        case .hasSameType(as: let other):
            try assertHasType(other.type, confidence: other.confidence)
        case .hasType(let dataType):
            try assertHasType(dataType, confidence: .certain)
        case .hasTypeIn(let dataTypes):
            try assertHasTypeIn(dataTypes, confidence: .certain)
        case .isImmutable:
            try assertHasMutability(false)
        case .isMutable:
            try assertHasMutability(true)
        case .isVariable:
            try assertIsVariable()
        }
    }

    func assert(_ assertions: [SymbolElementAssertion]) throws {
        for assertion in assertions {
            try assert(assertion)
        }
    }
}

extension Array where Element == Symbol {
    func assert(_ assertion: SymbolCollectionAssertion) throws {
        switch assertion {
        case .areVariables:
            try forEach { try $0.assertIsVariable() }
        case .haveCommonType:
            try assertHaveCommonType()
        case .haveCount(let comparator):
            try assertHaveCount(comparator)
        case .haveSameType(as: let other):
            try forEach { try $0.assertHasType(other.type, confidence: other.confidence) }
        case .haveType(let dataType):
            try forEach { try $0.assertHasType(dataType, confidence: .certain) }
        case .haveTypeIn(let dataTypes):
            try forEach { try $0.assertHasTypeIn(dataTypes, confidence: .certain) }
        }
    }

    func assert(_ assertions: [SymbolCollectionAssertion]) throws {
        for assertion in assertions {
            try assert(assertion)
        }
    }
}

// MARK: - Symbol element assertions

extension Symbol {
    func assertHasCategory(_ assertionCategory: Category) throws {
        switch self {
        case .definition(let definition):
            try definition.assertHasCategory(assertionCategory)
        case .literal(let literal):
            try literal.assertHasCategory(assertionCategory)
        case .statement(let statement):
            try statement.assertHasCategory(assertionCategory)
        case .instance(let instance):
            try instance.assertHasCategory(assertionCategory)
        case .variable(let variable):
            try variable.assertHasCategory(assertionCategory)
        }
    }

    func assertHasMutability(_ mutability: Bool) throws {
        switch self {
        case .definition(let definition):
            try definition.assertHasMutability(mutability)
        case .literal(let literal):
            try literal.assertHasMutability(mutability)
        case .statement(let statement):
            try statement.assertHasMutability(mutability)
        case .instance(let instance):
            try instance.assertHasMutability(mutability)
        case .variable(let variable):
            try variable.assertHasMutability(mutability)
        }
    }

    func assertHasReturnValue() throws {
        guard type?.hasReturnValue == true else {
            throw AssertionError.hasReturnValueAssertionFailed(
                for: "\(self)",
                asserted: true,
                actual: false
            )
        }
    }

    func assertHasType(
        _ dataType: DataType?,
        confidence assertionConfidence: DataType.Confidence?
    ) throws {
        switch self {
        case .definition(let definition):
            try definition.assertHasType(dataType, confidence: assertionConfidence)
        case .literal(let literal):
            try literal.assertHasType(dataType, confidence: assertionConfidence)
        case .statement(let statement):
            try statement.assertHasType(dataType, confidence: assertionConfidence)
        case .instance(let instance):
            try instance.assertHasType(dataType, confidence: assertionConfidence)
        case .variable(let variable):
            try variable.assertHasType(dataType, confidence: assertionConfidence)
        }
    }

    func assertHasTypeIn(
        _ dataTypes: [DataType],
        confidence assertionConfidence: DataType.Confidence?
    ) throws {
        for dataType in dataTypes {
            do {
                try assertHasType(dataType, confidence: assertionConfidence)
                return
            } catch {
                continue
            }
        }

        throw Symbol.AssertionError.hasTypeInAssertionFailed(
            for: "\(Self.self): \(code)",
            asserted: dataTypes,
            actual: type!
        )
    }

    func assertIsVariable() throws {
        switch self {
        case .instance, .variable: return
        default: throw AssertionError.isVariableAssertionFailed(for: "\(self)")
        }
    }
}

// MARK: - Symbol array assertions

extension Array where Element == Symbol {
    func assertHaveCommonType() throws {
        guard count > 1 else { return }

        guard let alpha = self.max(by: {
            $0.confidence ?? .unknown < $1.confidence ?? .unknown
        }) else { return }

        try assert(.haveSameType(as: alpha))
    }

    func assertHaveCount(_ comparator: SymbolCollectionCount) throws {
        switch comparator {
        case .atLeast(let int): if count >= int { return }
        case .exactly(let int): if count == int { return }
        case .between(let range): if range.contains(count) { return }
        }

        throw Symbol.AssertionError.haveCountAssertionFailed(
            asserted: comparator,
            actual: count,
            symbols: self
        )
    }
}

extension Symbol {
    enum AssertionError: Swift.Error {
        case hasCategoryAssertionFailed(for: String, asserted: Category, actual: Category)
        case hasMutabilityAssertionFailed(for: String, asserted: Bool, actual: Bool?)
        case hasReturnValueAssertionFailed(for: String, asserted: Bool, actual: Bool)
        case hasSameTypeAssertionFailed(for: String, asserted: DataType, actual: DataType)
        case hasTypeAssertionFailed(for: String, asserted: DataType, actual: DataType?)
        case hasTypeInAssertionFailed(for: String, asserted: [DataType], actual: DataType)
        case isImmutableAssertionFailed(for: String, asserted: Bool, actual: Bool?)
        case isMutableAssertionFailed(for: String, asserted: Bool, actual: Bool?)
        case isVariableAssertionFailed(for: String)

        case areVariablesAssertionFailed(asserted: Bool, actual: Bool)
        case haveCommonTypeFailed
        case haveCountAssertionFailed(
            asserted: SymbolCollectionCount,
            actual: Int,
            symbols: [Symbol]
        )
        case haveSameTypeAssertionFailed(asserted: Bool, actual: Bool)
        case haveTypeAssertionFailed(asserted: Bool, actual: Bool)
    }
}
