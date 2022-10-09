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
    case hasType(TypeInfo)
    case isImmutable
    case isMutable
    case isVariable
}

enum SymbolCollectionAssertion {
    case areVariables
    case haveCommonType
    case haveCount(SymbolCollectionCount)
    case haveReturnValues
    case haveSameType(as: Symbol)
    case haveType(TypeInfo)
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
            try assertHasType(other.type)
        case .hasType(let typeInfo):
            try assertHasType(typeInfo)
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
            try nonCommentSymbols.forEach { try $0.assertIsVariable() }
        case .haveCommonType:
            try nonCommentSymbols.assertHaveCommonType()
        case .haveCount(let comparator):
            try nonCommentSymbols.assertHaveCount(comparator)
        case .haveReturnValues:
            try nonCommentSymbols.forEach { try $0.assertHasReturnValue() }
        case .haveSameType(as: let other):
            try nonCommentSymbols.forEach { try $0.assertHasType(other.type) }
        case .haveType(let typeInfo):
            try nonCommentSymbols.forEach { try $0.assertHasType(typeInfo) }
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
        guard type.hasReturnValue == true else {
            throw AssertionError.hasReturnValueAssertionFailed(
                for: handle,
                asserted: true,
                actual: false
            )
        }
    }

    func assertHasType(_ assertedType: TypeInfo) throws {
        switch self {
        case .definition(let definition):
            try definition.assertHasType(assertedType)
        case .literal(let literal):
            try literal.assertHasType(assertedType)
        case .statement(let statement):
            try statement.assertHasType(assertedType)
        case .instance(let instance):
            try instance.assertHasType(assertedType)
        case .variable(let variable):
            try variable.assertHasType(assertedType)
        }
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
        guard
            count > 1,
            let alpha = self.max(by: { $0.type.confidence < $1.type.confidence })
        else { return }

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

    var nonCommentSymbols: [Symbol] {
        compactMap { symbol in
            guard
                case .statement(let statement) = symbol,
                statement.type == .comment
            else {
                return symbol
            }
            return nil
        }
    }
}

extension Symbol {
    enum AssertionError: Swift.Error {
        case hasCategoryAssertionFailed(for: String, asserted: Category, actual: Category)
        case hasMutabilityAssertionFailed(for: String, asserted: Bool, actual: Bool?)
        case hasReturnValueAssertionFailed(for: String, asserted: Bool, actual: Bool)
        case hasSameTypeAssertionFailed(for: String, asserted: TypeInfo, actual: TypeInfo)
        case hasTypeAssertionLiteralFailed(for: String, asserted: TypeInfo, actual: TypeInfo)
        case hasTypeAssertionStatementFailed(for: String, asserted: TypeInfo, actual: TypeInfo)
        case hasTypeAssertionVariableFailed(for: String, asserted: TypeInfo, actual: TypeInfo)
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
