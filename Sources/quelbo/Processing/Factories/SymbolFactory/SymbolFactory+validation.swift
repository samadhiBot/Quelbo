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
                to: Self.parameters.type(at: index),
                siblings: symbols
            )
        }
        switch Self.parameters {
        case .one, .oneOrMore, .twoOrMore:
            _ = try typedSymbols.commonType()
        default: break
        }

        types.register(typedSymbols)
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
        print("🍅 \(symbol): (\(symbol.type.isLiteral), \(declaredType.isLiteral)) [\(declaredType)]")
        if declaredType == .zilElement {
            return try assignZilElementType(on: symbol)
        }

        switch (symbol.type.isLiteral, declaredType.isLiteral) {
        case (true, true):
            if declaredType == .bool && symbol.type == .int {
                return Symbol(symbol.id == "0" ? "false" : "true", type: .bool, meta: [.isLiteral])
            }
            if symbol.type == declaredType {
                return symbol
            }
        case (true, false):
            if declaredType.acceptsLiteral || symbol.category == .properties {
                return symbol
            }
        case (false, true):
            return symbol.with(type: declaredType)
        case (false, false):
            if symbol.type.isContainer || symbol.type.hasKnownReturnValue {
                return symbol
            }
            return symbol.with(type: try siblings.commonType())
        }

        throw FactoryError.invalidType(symbol, expected: declaredType)
    }

    func assignZilElementType(on symbol: Symbol) throws -> Symbol? {
        switch symbol.type {
        case .array:
            if symbol.isPureTable {
                isMutable = false
                return nil
            }
            return symbol.with(
                code: ".table([\(symbol.children.codeValues(.commaSeparated))])",
                type: .zilElement
            )
        case .bool:
            return symbol.with(
                code: ".bool(\(symbol))",
                type: .zilElement,
                meta: symbol.meta
            )
        case .comment:
            return symbol.with(
                code: "// \(symbol)",
                type: .zilElement
            )
        case .int:
            return symbol.with(
                code: ".int(\(symbol))",
                type: .zilElement,
                meta: symbol.meta
            )
        case .object:
            if symbol.category == .rooms {
                return symbol.with(
                    code: ".room(\(symbol))",
                    type: .zilElement
                )
            } else {
                return symbol.with(
                    code: ".object(\(symbol))",
                    type: .zilElement
                )
            }
        case .string:
            return symbol.with(
                code: ".string(\(symbol))",
                type: .zilElement,
                meta: symbol.meta
            )
        case .zilElement:
            return symbol.with(
                code: ".table(\(symbol))",
                type: .zilElement
            )
        default:
            throw FactoryError.unexpectedZilElement(symbol)
        }
    }
}
