//
//  SymbolFactory+validation.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension SymbolFactory {
    func validate(_ symbols: [Symbol]) throws -> [Symbol] {
        let nonCommentParams = symbols.filter { $0.type != .comment }
        let numberRequired = Self.parameters.numberRequired
        guard numberRequired.contains(nonCommentParams.count) else {
            throw ValidationError.invalidParameterCount(
                nonCommentParams.count,
                expected: numberRequired,
                in: nonCommentParams,
                factory: self
            )
        }

        var index = 0
        let typedSymbols: [Symbol] = try symbols.compactMap { symbol in
            defer {
                if symbol.type != .comment { index += 1 }
            }

            return try assignType(
                of: symbol,
                to: Self.parameters.expectedType(at: index),
                siblings: symbols
            )
        }
        switch Self.parameters {
        case .one, .oneOrMore, .twoOrMore:
            guard typedSymbols.map(\.type).common != nil else {
                throw Symbol.Error.typeNotFound(typedSymbols)
            }
        default: break
        }

        try registry.register(typedSymbols)
        return typedSymbols
    }
}

// MARK: - Symbol type assignment

extension SymbolFactory {
    func assignType(
        of symbol: Symbol,
        to declaredType: Symbol.DataType,
        siblings: [Symbol]
    ) throws -> Symbol? {
        if declaredType == .zilElement {
            return try assignZilElementType(on: symbol)
        }
        if case .variable = declaredType, symbol.isLiteral && !symbol.isPlaceholderGlobal {
            throw ValidationError.expectedVariableFoundLiteral(symbol)
        }

        switch (symbol.type.isLiteral, declaredType.isLiteral) {
        case (true, true):
            if declaredType == .bool && symbol.type == .int {
                return symbol.with(
                    code: symbol.code == "0" ? "false" : "true",
                    type: .bool
                )
            }
            if [declaredType, .zilElement].contains(symbol.type) {
                return symbol
            }
            if declaredType.shouldReplaceType(in: symbol) {
                return symbol.with(type: declaredType)
            }
        case (true, false):
            if declaredType.shouldReplaceType(in: registry[symbol.id] ?? symbol) {
                return symbol.with(type: declaredType)
            }
            if declaredType.acceptsLiteral ||
                symbol.category == .properties ||
                declaredType.isUnknown && !symbol.type.isUnknown {
                return symbol
            }
        case (false, true):
            return symbol.with(type: declaredType)
        case (false, false):
            guard symbol.type.isProperty || symbol.type.hasKnownReturnValue else {
                return symbol.with(type: siblings.map(\.type).common)
            }
            if declaredType.isUnknown ||
                symbol.type == declaredType ||
                symbol.type == .optional(declaredType) {
                return symbol
            }
            if declaredType.shouldReplaceType(in: symbol) {
                return symbol.with(type: declaredType)
            }
        }

        //print("🍅 \(symbol): \(symbol.type)(\(declaredType)) (\(symbol.type.isLiteral), \(declaredType.isLiteral))")
        
        throw ValidationError.failedToDetermineType(
            symbol,
            expected: declaredType,
            found: symbol.type,
            siblings: siblings,
            in: self
        )
    }

    func assignZilElementType(on symbol: Symbol) throws -> Symbol? {
        switch symbol.type {
        case .array:
            if symbol.containsTableFlags {
                return symbol
            }
            return symbol.with(
                code: ".table([\(symbol.children.codeValues(.commaSeparated))])",
                type: .zilElement
            )
        case .bool:
            return symbol.with(
                code: ".bool(\(symbol.code))",
                type: .zilElement
            )
        case .comment:
            return symbol.with(
                code: "// \(symbol.code)",
                type: .zilElement
            )
        case .int:
            return symbol.with(
                code: ".int(\(symbol.code))",
                type: .zilElement
            )
        case .int8:
            return symbol.with(
                code: ".int8(\(symbol.code))",
                type: .zilElement
            )
        case .int16:
            return symbol.with(
                code: ".int16(\(symbol.code))",
                type: .zilElement
            )
        case .int32:
            return symbol.with(
                code: ".int32(\(symbol.code))",
                type: .zilElement
            )
        case .object:
            if symbol.category == .rooms {
                return symbol.with(
                    code: ".room(\(symbol.code))",
                    type: .zilElement
                )
            } else {
                return symbol.with(
                    code: ".object(\(symbol.code))",
                    type: .zilElement
                )
            }
        case .string:
            return symbol.with(
                code: ".string(\(symbol.code))",
                type: .zilElement
            )
        case .table:
            return symbol.with(
                code: ".table(\(symbol.code))",
                type: .zilElement
            )
        case .zilElement:
            return symbol.with(
                code: ".table(\(symbol.code))",
                type: .zilElement
            )
        case .direction, .optional, .property, .routine, .thing, .unknown, .void, .variable:
            throw ValidationError.unexpectedZilElement(symbol)
        }
    }
}

// MARK: - Errors

extension SymbolFactory {
    enum ValidationError: Swift.Error {
        case expectedVariableFoundLiteral(Symbol)
        case failedToDetermineType(
            Symbol,
            expected: Symbol.DataType,
            found: Symbol.DataType,
            siblings: [Symbol],
            in: SymbolFactory
        )
        case invalidParameterCount(
            Int,
            expected: ClosedRange<Int>,
            in: [Symbol],
            factory: SymbolFactory
        )
        case unexpectedZilElement(Symbol)
    }
}
