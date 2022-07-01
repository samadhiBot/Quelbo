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

        for symbol in typedSymbols {
            try upsert(symbol)
        }

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
        print("// 🍓 \(declaredType) => \(symbol)(\(symbol.type))")
        switch (declaredType, symbol.type) {
        case (.bool, .int):
            return symbol.with(
                type: .bool,
                meta: symbol.meta.withoutTypeCertainty
            )

        case (.property(let propertyType), _):
            if symbol.category == .properties || propertyType.isUnknown {
                return symbol
            }

        case (.unknown, _), (.array(.unknown), _):
            guard
                siblings.count > 1,
                let mostCertain = siblings.findByTypeCertainty()
            else { return symbol }

            return symbol.with(
                type: mostCertain.type,
                meta: symbol.meta.withTypeCertainty(of: mostCertain)
            )

        case (.variable(let declaredVariableType), .variable):
            guard
                declaredVariableType != .unknown,
                siblings.count > 1,
                let mostCertain = siblings.findByTypeCertainty()
            else {
                return symbol
            }

            return symbol.with(
                type: mostCertain.type.asVariable,
                meta: symbol.meta.withTypeCertainty(of: mostCertain)
            )

        case (.variable, _):
            throw ValidationError.expectedVariableFoundLiteral(symbol)

        case (.zilElement, _):
            return try assignZilElementType(on: symbol)

        case (_, .property(let propertyType)):
            if declaredType == propertyType {
                return symbol
            }

        case (_, .variable(let variableType)):
            if declaredType == variableType {
                return symbol
            }

        default:
            if [declaredType, .zilElement].contains(symbol.type) {
                return symbol
            }
        }

        guard symbol.typeCertainty < .certain else {
            throw ValidationError.failedToDetermineType(
                symbol,
                expected: declaredType,
                found: symbol.type,
                siblings: siblings,
                in: self
            )
        }

        print("// 🍌 \(declaredType) ==>> \(symbol)")

        let childType = declaredType.isLiteral ? declaredType : .optional(declaredType)
        var parentType = childType
        if case .variable = symbol.type {
            parentType = childType.asVariable
        }

        return symbol.with(
            type: parentType,
            children: symbol.children.map { child in
                guard child.typeCertainty < .certain else { return child }

                return child.with(
                    type: childType,
                    meta: child.meta.withoutTypeCertainty
                )
            },
            meta: symbol.meta.withoutTypeCertainty
        )

//        switch (symbol.type.isLiteral, declaredType.isLiteral) {
//        case (true, true):
//            if declaredType == .bool && symbol.type == .int {
//                return symbol.with(
//                    code: symbol.code == "0" ? "false" : "true",
//                    type: .bool
//                )
//            }
//            if [declaredType, .zilElement].contains(symbol.type) {
//                return symbol
//            }
//            if let updated = declaredType.replacingType(in: symbol) {
//                return updated
//            }
//        case (true, false):
//            if let updated = declaredType.replacingType(in: findRegistered(symbol.id) ?? symbol) {
//                return updated
//            }
//            if declaredType.acceptsLiteral ||
//                symbol.category == .properties ||
//                declaredType.isUnknown && !symbol.type.isUnknown {
//                return symbol
//            }
//        case (false, true):
//            return symbol.with(type: declaredType)
//        case (false, false):
//            guard symbol.type.isProperty || symbol.type.hasKnownReturnValue else {
//                return symbol.with(type: siblings.map(\.type).common)
//            }
//            if declaredType.isUnknown ||
//                symbol.type == declaredType ||
//                symbol.type == .optional(declaredType) {
//                return symbol
//            }
//            if let updated = declaredType.replacingType(in: symbol) {
//                return updated
//            }
//        }
    }

    func assignZilElementType(on symbol: Symbol) throws -> Symbol? {
        switch symbol.type {
        case .array:
            if symbol.containsTableFlags {
                return symbol
            }
            return symbol
                .with(code: ".table([\(symbol.children.codeValues(.commaSeparated))])")
                .with(type: .zilElement)
        case .bool:
            return symbol
                .with(code: ".bool(\(symbol.code))")
                .with(type: .zilElement)
        case .comment:
            return symbol
                .with(code: "// \(symbol.code)")
                .with(type: .zilElement)
        case .int:
            return symbol
                .with(code: ".int(\(symbol.code))")
                .with(type: .zilElement)
        case .int8:
            return symbol
                .with(code: ".int8(\(symbol.code))")
                .with(type: .zilElement)
        case .int16:
            return symbol
                .with(code: ".int16(\(symbol.code))")
                .with(type: .zilElement)
        case .int32:
            return symbol
                .with(code: ".int32(\(symbol.code))")
                .with(type: .zilElement)
        case .object:
            if symbol.category == .rooms {
                return symbol
                    .with(code: ".room(\(symbol.code))")
                    .with(type: .zilElement)
            } else {
                return symbol
                    .with(code: ".object(\(symbol.code))")
                    .with(type: .zilElement)
            }
        case .string:
            return symbol
                .with(code: ".string(\(symbol.code))")
                .with(type: .zilElement)
        case .table:
            return symbol
                .with(code: ".table(\(symbol.code))")
                .with(type: .zilElement)
        case .zilElement:
            return symbol
                .with(code: ".table(\(symbol.code))")
                .with(type: .zilElement)
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
