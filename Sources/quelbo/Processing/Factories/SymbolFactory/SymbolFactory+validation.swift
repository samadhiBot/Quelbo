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
            throw FactoryError.invalidParameterCount(
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
            throw FactoryError.unexpectedParameter(symbol)
        }

        switch (symbol.type.isLiteral, declaredType.isLiteral) {
        case (true, true):
            if declaredType == .bool && symbol.type == .int {
                return symbol.with(code: symbol.id == "0" ? "false" : "true", type: .bool)
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

        throw FactoryError.invalidType(symbol, expected: declaredType, found: symbol.type)
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
            return symbol.with(code: ".bool(\(symbol))", type: .zilElement)
        case .comment:
            return symbol.with(code: "// \(symbol)", type: .zilElement)
        case .int:
            return symbol.with(code: ".int(\(symbol))", type: .zilElement)
        case .object:
            if symbol.category == .rooms {
                return symbol.with(code: ".room(\(symbol))", type: .zilElement)
            } else {
                return symbol.with(code: ".object(\(symbol))", type: .zilElement)
            }
        case .string:
            return symbol.with(code: ".string(\(symbol))", type: .zilElement)
        case .table:
            return symbol.with(code: ".table(\(symbol))", type: .zilElement)
        case .zilElement:
            return symbol.with(code: ".table(\(symbol))", type: .zilElement)
        case .direction, .property, .routine, .thing, .unknown, .void, .variable:
            throw FactoryError.unexpectedZilElement(symbol)
        }
    }
}
