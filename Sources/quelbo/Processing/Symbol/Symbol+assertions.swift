//
//  Symbol+Assertions.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/12/22.
//

import Foundation

enum SymbolElementAssertion {
    case hasCategory(Category)
    case hasKnownType
    case hasMutability(Bool)
    case hasReturnValue
    case hasSameCategory(as: Symbol)
    case hasSameType(as: Symbol)
    case hasType(TypeInfo)
    case isArray
    case isImmutable
    case isMutable
    case isOptional
    case isProperty
    case isTableElement
    case isVariable
}

enum SymbolCollectionAssertion {
    case areTableElements
    case areVariables
    case haveCommonType
    case haveCount(SymbolCollectionCount)
    case haveKnownType
    case haveReturnHandling(Symbol.ReturnHandling)
    case haveReturnValues
    case haveSameType(as: Symbol)
    case haveSingleReturnType
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
        case .hasKnownType:
            try assertHasKnownType()
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
        case .isArray:
            try assertIsArray()
        case .isImmutable:
            try assertHasMutability(false)
        case .isMutable:
            try assertHasMutability(true)
        case .isOptional:
            try assertIsOptional()
        case .isProperty:
            try assertIsProperty()
        case .isTableElement:
            try assertIsTableElement()
        case .isVariable:
            try assertIsVariable()
        }
    }

    func assert(_ assertions: SymbolElementAssertion...) throws {
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
        case .areTableElements:
            try nonCommentSymbols.forEach { try $0.assertIsTableElement() }
        case .haveCommonType:
            try nonCommentSymbols.assertHaveCommonType()
        case .haveCount(let comparator):
            try nonCommentSymbols.assertHaveCount(comparator)
        case .haveKnownType:
            try nonCommentSymbols.forEach { try $0.assertHasKnownType() }
        case .haveReturnHandling(let handling):
            try nonCommentSymbols.forEach { try $0.assertHasReturnHandling(handling) }
        case .haveReturnValues:
            try nonCommentSymbols.forEach { try $0.assertHasReturnValue() }
        case .haveSameType(as: let other):
            try nonCommentSymbols.forEach { try $0.assertHasType(other.type) }
        case .haveSingleReturnType:
            try nonCommentSymbols.assertHaveSingleReturnType()
        case .haveType(let typeInfo):
            try nonCommentSymbols.forEach { try $0.assertHasType(typeInfo) }
        }
    }

    func assert(_ assertions: SymbolCollectionAssertion...) throws {
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
            try instance.variable.assertHasCategory(assertionCategory)
        }
    }

    func assertHasKnownType() throws {
        guard type.confidence > .none else {
            throw AssertionError.hasKnownTypeAssertionFailed(for: handle)
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
        }
    }

    func assertHasReturnValue() throws {
        guard type.hasReturnValue || returnHandling > .suppressed else {
            throw AssertionError.hasReturnValueAssertionFailed(
                for: handle,
                asserted: true,
                actual: false
            )
        }
        try assertHasReturnHandling(.forced)
    }

    func assertHasReturnHandling(_ handling: Symbol.ReturnHandling) throws {
        switch self {
        case .definition(let definition):
            try definition.assertHasReturnHandling(handling)
        case .literal(let literal):
            try literal.assertHasReturnHandling(handling)
        case .statement(let statement):
            try statement.assertHasReturnHandling(handling)
        case .instance(let instance):
            try instance.assertHasReturnHandling(handling)
        }
    }

    func assertHasType(_ assertedType: TypeInfo) throws {
        if assertedType === type { return }

        switch self {
        case .definition(let definition):
            try definition.assertHasType(assertedType)
        case .literal(let literal):
            try literal.assertHasType(assertedType)
        case .statement(let statement):
            try statement.assertHasType(assertedType)
        case .instance(let instance):
            try instance.variable.assertHasType(assertedType)
        }
    }

    func assertIsArray() throws {
        try type.assertIsArray()
    }

    func assertIsOptional() throws {
        try type.assertIsOptional()
    }

    func assertIsProperty() throws {
        try type.assertIsProperty()
    }

    func assertIsTableElement() throws {
        try type.assertIsTableElement()
    }

    func assertIsVariable() throws {
        switch self {
        case .definition, .literal: break
        case .statement(let statement):
            guard statement.id != nil else { break }
            if statement.type.dataType == .table {
                try type.assertIsTableElement(false)
            }
            return
        case .instance: return
        }
        throw AssertionError.isVariableAssertionFailed(for: "\(self)")
    }
}

// MARK: - Symbol array assertions

extension Array where Element == Symbol {
    func assertHaveCommonType() throws {
        guard count > 1 else { return }

        let alphas = withMaxConfidence
        let uniqueTypes = alphas
            .filter { $0.type != .void }
            .compactMap(\.type.dataType)
            .unique

        switch uniqueTypes.count {
        case 0, 1:
            try assert(
                .haveSameType(as: alphas[0])
            )
        case 2:
            if let optionalType = alphas.sharedOptionalType {
                try assert(
                    .haveType(optionalType)
                )
            } else {
                fallthrough
            }
        default:
            try? assert(
                .areTableElements
            )
        }
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

    func assertHaveSingleReturnType() throws {
        let (explicitlyReturning, nonReturning) = {
            let returningSymbols = explicitlyReturningSymbols
            if !returningSymbols.isEmpty {
                return returningSymbols.splitByReturnHandling
            }
            if let lastSymbol = implicitlyReturningLastSymbol {
                return ([lastSymbol], [])
            }
            return ([], [])
        }()
        let alphas = explicitlyReturning.withMaxConfidence
        let uniqueTypes = alphas.returnTypes

        /*
         Swift.print(
             "😀 assertHaveSingleReturnType",
             "\nsymbols:\n\(self.map({ "\($0.handle) [\($0.returnHandling)]" }).joined(separator: "\n").indented)",
             "\nreturningSymbols:\n\(returningSymbols.handles(.singleLineBreak).indented)",
             "\nexplicitlyReturning:\n\(explicitlyReturning.handles(.singleLineBreak).indented)",
             "\nnonReturning:\n\(nonReturning.handles(.singleLineBreak).indented)",
             "\nalphas:\n\(alphas.map { "\($0.handle) [\($0.type.debugDescription)]" }.values(.singleLineBreak).indented)",
             "\nuniqueTypes:", uniqueTypes
         )
         */

        func assertType(_ type: TypeInfo) throws {
            try explicitlyReturning.assert(
                .haveType(type),
                .haveReturnHandling(.forced)
            )

            try nonReturning.assert(
                .haveReturnHandling(.suppressed)
            )
        }

        switch uniqueTypes.count {
        case 0:
            return
        case 1:
            try assertType(alphas[0].type)
        case 2:
            if let optionalType = alphas.sharedOptionalType {
                try assertType(optionalType)
            } else {
                fallthrough
            }
        default:
            try assert(
                .areTableElements
            )
        }
    }
}

extension Symbol {
    enum AssertionError: Swift.Error {
        case hasCategoryAssertionFailed(for: String, asserted: Category, actual: Category)
        case hasKnownTypeAssertionFailed(for: String)
        case hasMutabilityAssertionFailed(for: String, asserted: Bool, actual: Bool?)
        case hasReturnHandlingAssertionFailed(
            for: String,
            asserted: Symbol.ReturnHandling,
            actual: Symbol.ReturnHandling
        )
        case hasReturnValueAssertionFailed(for: String, asserted: Bool, actual: Bool)
        case hasSameTypeAssertionFailed(for: String, asserted: TypeInfo, actual: TypeInfo)
        case hasTypeAssertionFailed(for: String, asserted: TypeInfo, actual: TypeInfo)
        case isImmutableAssertionFailed(for: String, asserted: Bool, actual: Bool?)
        case isMutableAssertionFailed(for: String, asserted: Bool, actual: Bool?)
        case isVariableAssertionFailed(for: String)

        case isArrayAssertionFailed
        case isOptionalAssertionFailed
        case isPropertyAssertionFailed
        case isTableElementAssertionFailed
        case shouldReturnAssertionFailed

        case areVariablesAssertionFailed(asserted: Bool, actual: Bool)
        case haveCountAssertionFailed(
            asserted: SymbolCollectionCount,
            actual: Int,
            symbols: [Symbol]
        )
        case haveSameTypeAssertionFailed(asserted: Bool, actual: Bool)
        case haveTypeAssertionFailed(asserted: Bool, actual: Bool)
    }
}
