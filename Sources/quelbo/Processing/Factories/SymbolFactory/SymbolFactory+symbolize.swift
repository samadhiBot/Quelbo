//
//  SymbolFactory+symbolize.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension SymbolFactory {
    /// Translates a ``Token`` array into a ``Symbol`` array.
    ///
    /// - Parameters:
    ///   - zilTokens: A ``Token`` array to translate into symbols.
    ///
    /// - Returns: A ``Symbol`` array corresponding to the translated tokens.
    ///
    /// - Throws: When token translation fails.
    func symbolize(_ zilTokens: [Token]) throws -> [Symbol] {
        var symbols: [Symbol] = []
        var zilTokens = zilTokens

        while let zilToken = zilTokens.shift() {
            switch zilToken {
            case .atom(let string):
                symbols.append(
                    try symbolizeAtom(string, at: symbols.count)
                )
            case .bool(let bool):
                symbols.append(
                    symbolizeBoolean(bool)
                )
            case .character(let character):
                symbols.append(
                    Symbol(character.quoted, type: .string, meta: [.isLiteral])
                )
            case .commented(let token):
                symbols.append(Symbol("/* \(token.value) */", type: .comment))
            case .decimal(let int):
                symbols.append(
                    symbolizeDecimal(int)
                )
            case .eval(let token):
                symbols.append(
                    try symbolizeEval(token)
                )
            case .form(let tokens):
                symbols.append(
                    try symbolizeForm(tokens)
                )
            case .global(let string):
                symbols.append(
                    try symbolizeGlobal(string, at: symbols.count)
                )
            case .list(let tokens):
                symbols.append(
                    try symbolizeList(tokens)
                )
            case .local(let string):
                symbols.append(
                    try symbolizeLocal(string, at: symbols.count)
                )
            case .property(let string):
                symbols.append(
                    try symbolizeProperty(string)
                )
            case .quote(let token):
                symbols.append(
                    try symbolizeQuote(token)
                )
            case .segment(let token):
                symbols.append(
                    try symbolizeSegment(token)
                )
            case .string(let string):
                symbols.append(
                    Symbol(string.quoted, type: .string, meta: [.isLiteral])
                )
            case .type(let token):
                symbols.append(
                    try symbolizeType(token, siblings: &zilTokens)
                )
            case .vector(let tokens):
                symbols.append(
                    try symbolizeList(tokens)
                )
            }
        }
        symbols = try validate(symbols)

        return symbols
    }

    /// Translates a ``Token`` into a ``Symbol``.
    ///
    /// - Parameters:
    ///   - zilToken: A ``Token`` to translate into a symbol.
    ///
    /// - Returns: A ``Symbol`` corresponding to the translated tokens.
    ///
    /// - Throws: When token translation fails.
    func symbolize(_ token: Token) throws -> Symbol {
        let symbols = try symbolize([token])
        guard symbols.count == 1 else {
            throw SymbolizationError.singleTokenSymbolizationFailed(token)
        }
        return symbols[0]
    }

    /// Translates a Zil [Atom](https://mdl-language.readthedocs.io/en/latest/04-values-of-atoms/)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameters:
    ///   - zil: The original Zil atom name.
    ///   - index: The index at which the atom occurs in a block of Zil code.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil atom.
    func symbolizeAtom(
        _ zil: String,
        at index: Int
    ) throws -> Symbol {
        let name = zil.lowerCamelCase
        let expectedType = try Self.parameters.expectedType(at: index)
        if let defined = try? Game.find(.id(name), type: expectedType) {
            return defined.with(code: name)
        }
        if zil == "T" {
            switch expectedType {
            case .variable: break
            default: return .trueSymbol
            }
        }
        return Symbol(name, type: expectedType)
    }

    /// Translates a Zil
    /// [Boolean](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3znysh7)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameter value: A boolean value.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil boolean.
    func symbolizeBoolean(_ value: Bool) -> Symbol {
        var metaData: [Symbol.MetaData] = [.isLiteral]
        if value == false {
            metaData.append(.maybeEmptyValue)
        }
        return Symbol("\(value)", type: .bool, meta: metaData)
    }

    /// Translates a Zil
    /// [Character](https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#766-string-the-primtype-and-character-1)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameter zil: The original Zil character as a `String`.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil character.
    func symbolizeCharacter(_ zil: String) throws -> Symbol {
        Symbol(zil.quoted, type: .string, meta: [.isLiteral])
    }

    /// Translates a Zil
    /// [Boolean](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3znysh7)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameter value: A boolean value.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil boolean.
    func symbolizeDecimal(_ value: Int) -> Symbol {
        var metaData: [Symbol.MetaData] = [.isLiteral]
        if value == 0 {
            metaData.append(.maybeEmptyValue)
        }
        return Symbol("\(value)", type: .int, meta: metaData)
    }

    /// Translates a Zil
    /// ["% notation"](https://mdl-language.readthedocs.io/en/latest/17-macro-operations/#171-read-macros)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameter evalToken: The Zil token that was marked for immediate evaluation.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil character.
    func symbolizeEval(_ evalToken: Token) throws -> Symbol {
        try symbolize(evalToken)
//        guard let symbol = try symbolize([evalToken]).first else {
//            throw SymbolizationError.invalidProperty(evalToken)
//        }
//        return symbol
    }

    /// Translates a Zil
    /// [Form](https://mdl-language.readthedocs.io/en/latest/03-built-in-functions/#31-representation-1)
    /// token into a ``Symbol``.
    ///
    /// - Parameter formTokens: A `Token` array consisting of the Zil form elements.
    ///
    /// - Returns: A ``Symbol`` representation of the Zil form.
    func symbolizeForm(_ formTokens: [Token]) throws -> Symbol {
        var tokens = formTokens

        let zil: String
        switch tokens.shift() {
        case .atom(let name):
            zil = name
        case .decimal(let nth):
            zil = "NTH"
            tokens.append(.decimal(nth))
        case .form:
            var nested = try symbolize(formTokens)
            guard
                let closure = nested.shift(),
                closure.isFunctionClosure
            else {
                throw SymbolizationError.invalidZilForm(formTokens)
            }
            return Symbol(
                "\(closure.code)(\(nested.codeValues(.commaSeparated)))",
                type: closure.type,
                children: nested
            )
        case .global(let name):
            zil = name
        case .local(let name):
            zil = name
        default:
            throw SymbolizationError.invalidZilForm(formTokens)
        }

        func findFactory() throws -> SymbolFactory {
            if let zMachine = try Game.zMachineSymbolFactories.find(zil)?.init(
                tokens,
                in: blockType,
                with: types
            ) {
                return zMachine
            }
            let id = Symbol.Identifier.id(zil.lowerCamelCase)
            if let _ = try? Game.find(id, category: .routines) {
                return try Factories.RoutineCall(formTokens, with: types)
            }
            if let _ = try? Game.find(id, category: .definitions) {
                let _ = try Factories.DefinitionEval(formTokens, with: types).process()
                return try Factories.RoutineCall(formTokens, with: types)
            }
            throw SymbolizationError.noRoutineOrDefinition(formTokens)
        }

        let factory = try findFactory()
        let symbol = try factory.process()
        self.isMutable = factory.isMutable
        return symbol
    }

    /// Translates a Zil
    /// [Global](https://mdl-language.readthedocs.io/en/latest/04-values-of-atoms/#42-global-values)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameters:
    ///   - zil: The original Zil atom.
    ///   - index: The index at which the global occurs in a block of Zil code.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil global atom.
    func symbolizeGlobal(
        _ zil: String,
        at index: Int
    ) throws -> Symbol {
        let name = zil.lowerCamelCase
        return try Game.find(.id(name)).with(code: name)
    }

    /// Translates a Zil
    /// [List](https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#721-list-1)
    /// token into a ``Symbol``.
    ///
    /// - Parameter listTokens: A `Token` array consisting of the Zil list elements.
    ///
    /// - Returns: A ``Symbol`` representation of the Zil list.
    func symbolizeList(_ listTokens: [Token]) throws -> Symbol {
        try Factories.List(listTokens, in: blockType, with: types).process()
    }

    /// Translates a Zil
    /// [Local](https://mdl-language.readthedocs.io/en/latest/04-values-of-atoms/#43-local-values)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameters:
    ///   - zil: The original Zil atom.
    ///   - index: The index at which the local occurs in a block of Zil code.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil local atom.
    func symbolizeLocal(
        _ zil: String,
        at index: Int
    ) throws -> Symbol {
        let name = zil.lowerCamelCase
        let localType = try findType(of: .id(name), at: index)
        return Symbol(name, type: localType)
    }

    /// Translates a Zil Object
    /// [Property](https://mdl-language.readthedocs.io/en/latest/13-association-properties/)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameter property: The original Zil atom.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil object property.
    func symbolizeProperty(_ property: String) throws -> Symbol {
        var category: Symbol.Category
        var type: Symbol.DataType
        if let property = try? Game.zilPropertyFactories.find(property) {
            category = .properties
            type = property.returnType
        } else if let _ = try? Game.find(
            .id(property.lowerCamelCase),
            category: .properties
        ) {
            category = .directions
            type = .direction
        } else {
            throw SymbolizationError.unknownZilProperty(property)
        }
        return Symbol(
            property.lowerCamelCase,
            type: type,
            category: category
        )
    }

    /// Translates a Zil
    /// [Quote](https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#752-quote-1)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameter quote: The quoted Zil element.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil quote.
    func symbolizeQuote(_ token: Token) throws -> Symbol {
        try Factories.Quote([token]).process()
    }

    /// Translates a Zil
    /// [Segment](https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#77-segments-1)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameter segment: The segmented Zil element.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil segment.
    func symbolizeSegment(_ token: Token) throws -> Symbol {
        try Factories.Segment([token]).process()
    }

    /// Translates a Zil
    /// ["# notation"](https://mdl-language.readthedocs.io/en/latest/06-data-types/#634-chtype-1)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameters:
    ///   - segment: The segmented Zil element.
    ///   - siblings: The tokens following the `"# notation"` token.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil segment.
    func symbolizeType(_ type: String, siblings: inout [Token]) throws -> Symbol {
        switch type {
        case "BYTE":
            guard case .decimal(let value) = siblings.shift() else {
                throw SymbolizationError.missingDeclarationValue(siblings)
            }
            return Symbol("\(value)", type: .int8, meta: [.isLiteral])
        case "DECL":
            guard case .list(let tokens) = siblings.shift() else {
                throw SymbolizationError.missingDeclarationValue(siblings)
            }
            return try Factories.DeclareType(tokens, with: types).process()
        case "SPLICE":
            return Symbol("SPLICE (not yet implemented)")
        default:
            throw SymbolizationError.unknownType(type)
        }
    }

    /// Translates a Zil
    /// [Vector](https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#722-vector-1)
    /// token into a ``Symbol``.
    ///
    /// - Parameter vectorTokens: A `Token` array consisting of the Zil vector elements.
    ///
    /// - Returns: A ``Symbol`` representation of the Zil vector.
    func symbolizeVector(_ vectorTokens: [Token]) throws -> Symbol {
        try Factories.Vector(vectorTokens, with: types).process()
    }
}

// MARK: - Errors

extension SymbolFactory {
    enum SymbolizationError: Swift.Error {
        case invalidZilForm([Token])
        case noRoutineOrDefinition([Token])
        case singleTokenSymbolizationFailed(Token)
        case unknownZilProperty(String)
        case unknownType(String)
        case missingDeclarationValue([Token])
    }
}
