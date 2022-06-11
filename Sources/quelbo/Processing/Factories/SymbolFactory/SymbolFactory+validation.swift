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
        guard Self.parameters.range.contains(nonCommentParams.count) else {
            throw ValidationError.invalidParameterCount(
                nonCommentParams.count,
                expected: Self.parameters.range,
                in: nonCommentParams
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
            guard typedSymbols.commonType() != nil else {
                throw Symbol.Error.typeNotFound(typedSymbols)
            }
        default: break
        }

        try types.register(typedSymbols)
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
        // print("🍅 \(symbol): \(symbol.type)(\(declaredType)) (\(symbol.type.isLiteral), \(declaredType.isLiteral))")
        if declaredType == .zilElement {
            return try assignZilElementType(on: symbol)
        }
        if case .variable = declaredType, symbol.isLiteral {
            throw ValidationError.expectedVariableFoundLiteral(symbol)
        }

        switch (symbol.type.isLiteral, declaredType.isLiteral) {
        case (true, true):
            if declaredType == .bool && symbol.type == .int {
                return symbol.with(
                    code: symbol.id == "0" ? "false" : "true",
                    type: .bool
                )
            }
            if [declaredType, .zilElement].contains(symbol.type) {
                return symbol
            }
        case (true, false):
            if declaredType.acceptsLiteral || symbol.category == .properties {
                return symbol
            }
            if declaredType.supersedes(symbol.id) {
                return symbol.with(type: declaredType)
            }
            if declaredType.isUnknown && !symbol.type.isUnknown {
                return symbol
            }
        case (false, true):
            return symbol.with(type: declaredType)
        case (false, false):
            if symbol.type.isContainer || symbol.type.hasKnownReturnValue {
                return symbol
            }
            return symbol.with(type: siblings.commonType())
        }

        throw ValidationError.failedToDetermineType(
            symbol,
            expected: declaredType,
            found: symbol.type,
            siblings: siblings
        )
    }

    func assignZilElementType(on symbol: Symbol) throws -> Symbol? {
        switch symbol.type {
        case .array:
            if symbol.containsTableFlags {
                return symbol.with(id: "<Flags>")
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
        case .direction, .property, .routine, .thing, .unknown, .void, .variable:
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
            siblings: [Symbol]
        )
        case invalidParameterCount(Int, expected: ClosedRange<Int>, in: [Symbol])
        case unexpectedZilElement(Symbol)
    }
}
