//
//  Factories.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

/// Namespace for symbol factories that translate a ``Token`` array to a ``Symbol`` array.
enum Factories {}

// MARK: - FactoryError

enum FactoryError: Swift.Error {
    case evaluationFailed(Token)
    case foundMultipleMatchingFactories(zil: String, matches: [SymbolFactory.Type])
    case incorrectParameters([Token], expected: String)
    case indeterminateTypes([Token], types: [Symbol.DataType])
    case invalidConditionExpression([Symbol])
    case invalidConditionList([Token])
    case invalidConditionPredicate([Symbol])
    case invalidDirection([Token])
    case invalidParameter([Symbol])
    case invalidParameterCount(Int, expected: ClosedRange<Int>, in: [Symbol])
    case invalidProperty(Token)
    case invalidType(Symbol, expected: Symbol.DataType)
    case invalidTypeLookup(at: Int)
    case invalidValue(Symbol)
    case invalidZilForm([Token])
    case missingName([Token])
    case missingParameter(Symbol)
    case missingParameters([Token])
    case missingPropertyValues(Symbol)
    case missingTypeToken([Token])
    case missingValue([Token])
    case outOfRangeSymbolIndex(Int, [Symbol])
    case unconsumedTokens([Token])
    case unexpectedParameter(Symbol)
    case unexpectedZilElement(Symbol)
    case unexpectedTypeParameter([Token], expected: Symbol.DataType, found: [Symbol.DataType])
    case unimplemented(SymbolFactory)
    case unknownProperty(String)
    case unknownType([Token])
    case unknownZMachineFunction(zil: String)
    case unknownZilFunction(zil: String)
}
