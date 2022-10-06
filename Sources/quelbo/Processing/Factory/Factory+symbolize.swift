//
//  Factory+symbolize.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension Factory {
    /// Translates a ``Token`` array into a ``Symbol`` array.
    ///
    /// - Parameters:
    ///   - zilTokens: A ``Token`` array to translate into symbols.
    ///
    /// - Returns: A ``Symbol`` array corresponding to the translated tokens.
    ///
    /// - Throws: When token translation fails.
    func symbolize(
        _ tokens: [Token],
        mode factoryMode: FactoryMode? = nil
    ) throws -> [Symbol] {
        var tokens = tokens
        var symbols: [Symbol] = []

        while let token = tokens.shift() {
            switch token {
            case .atom(let string):
                symbols.append(try symbolizeAtom(string))

            case .bool(let bool):
                symbols.append(.literal(bool))

            case .character(let character):
                symbols.append(.literal(character))

            case .commented(let token):
                symbols.append(.statement(
                    code: { _ in token.value.commented },
                    type: .comment
                ))

            case .decimal(let int):
                symbols.append(.literal(int))

            case .eval(let token):
                symbols.append(try symbolizeEval(token))

            case .form(let tokens):
                symbols.append(try symbolizeForm(tokens, mode: factoryMode))

            case .global(let string):
                symbols.append(try symbolizeGlobal(string))

            case .list(let tokens):
                symbols.append(try symbolizeList(tokens))

            case .local(let string):
                symbols.append(try symbolizeLocal(string))

            case .property(let string):
                symbols.append(try symbolizeProperty(string, siblings: &tokens))

            case .quote(let token):
                symbols.append(try symbolizeQuote(token))

            case .segment(let token):
                symbols.append(try symbolizeSegment(token))

            case .string(let string):
                symbols.append(.literal(string))

            case .type(let token):
                symbols.append(try symbolizeType(token, siblings: &tokens))

            case .vector(let tokens):
                symbols.append(try symbolizeList(tokens))

            case .verb(let rawVerb):
                symbols.append(.verb(rawVerb))
            }
        }

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
    func symbolize(
        _ token: Token,
        mode factoryMode: FactoryMode? = nil
    ) throws -> Symbol {
        let symbols = try symbolize([token], mode: factoryMode ?? mode)
        guard symbols.count == 1 else {
            throw SymbolizationError.singleTokenSymbolizationFailed(token)
        }
        return symbols[0]
    }

    /// Translates a Zil [Atom](https://mdl-language.readthedocs.io/en/latest/04-values-of-atoms/)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameter zil: The original Zil atom name.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil atom.
    func symbolizeAtom(_ zil: String) throws -> Symbol {
        let name = zil.lowerCamelCase

        if let global = Game.findGlobal(name) { return .instance(global) }
        if let local = findLocal(name) { return .variable(local) }
        if let known = knownVariable(zil) { return .variable(known) }
        if zil == "T" { return .literal(true) }
        if Game.findDefinition(name) != nil {
            return try Factories.DefinitionEvaluate(
                [.atom(zil)],
                with: &localVariables).process(
            )
        }

        return .variable(id: name, type: .unknown)
    }

    /// Translates a Zil
    /// ["% notation"](https://mdl-language.readthedocs.io/en/latest/17-macro-operations/#171-read-macros)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameter evalToken: The Zil token that was marked for immediate evaluation.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil character.
    func symbolizeEval(_ evalToken: Token) throws -> Symbol {
        try symbolize(evalToken, mode: .evaluate)
    }

    /// Translates a Zil
    /// [Form](https://mdl-language.readthedocs.io/en/latest/03-built-in-functions/#31-representation-1)
    /// token into a ``Symbol``.
    ///
    /// - Parameter formTokens: A `Token` array consisting of the Zil form elements.
    ///
    /// - Returns: A ``Symbol`` representation of the Zil form.
    func symbolizeForm(
        _ formTokens: [Token],
        mode factoryMode: FactoryMode? = nil
    ) throws -> Symbol {
        var tokens = formTokens

        let zilString: String
        switch tokens.first {
        case .atom(let name):
            zilString = name

        case .decimal(let nth):
            zilString = "NTH"
            tokens.append(.decimal(nth))

        case .form:
            var nested = try symbolize(formTokens)
            guard let closure = nested.shift() else {
                throw SymbolizationError.invalidZilForm(formTokens)
            }
            return .statement(
                code: { _ in
                    if nested.isEmpty {
                        return closure.code
                    } else {
                        return "\(closure.code)(\(nested.codeValues(.commaSeparated)))"
                    }
                },
                type: closure.type
            )

        case .global(let name):
            zilString = name

        case .local(let name):
            zilString = name

        default:
            throw SymbolizationError.invalidZilForm(formTokens)
        }

        let factory = try Game.makeFactory(
            zil: zilString,
            tokens: tokens,
            with: &localVariables,
            type: .zCode,
            mode: factoryMode ?? mode
        )

        return try factory.process()
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
    func symbolizeGlobal(_ zil: String) throws -> Symbol {
        let id = zil.lowerCamelCase

        if let global = Game.findGlobal(id) { return .variable(global)}
        if let found = Game.shared.symbols.find(id) { return .statement(found)}
        if let flag = Game.flags.find(id) { return .statement(flag)}
        if mode == .evaluate { return .variable(id: id, type: .unknown) }

        throw GameError.globalNotFound(id)
    }

    /// Translates a Zil
    /// [List](https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#721-list-1)
    /// token into a ``Symbol``.
    ///
    /// - Parameter listTokens: A `Token` array consisting of the Zil list elements.
    ///
    /// - Returns: A ``Symbol`` representation of the Zil list.
    func symbolizeList(_ listTokens: [Token]) throws -> Symbol {
        try Factories.List(listTokens, with: &localVariables).process()
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
    func symbolizeLocal(_ zil: String) throws -> Symbol {
        guard let found = localVariables.first(where: { $0.id == zil.lowerCamelCase }) else {
            throw SymbolizationError.unknownLocal(zil)
        }
        return .variable(found)
    }

    /// Translates a Zil Object
    /// [Property](https://mdl-language.readthedocs.io/en/latest/13-association-properties/)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameter property: The original Zil atom.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil object property.
    func symbolizeProperty(_ zil: String, siblings: inout [Token]) throws -> Symbol {
        if let factory = Game.findFactory(zil, type: .property) {
            return try factory.init(siblings, with: &localVariables).process()
        }

        guard
            let direction = Game.properties.find(zil.lowerCamelCase),
            let code = direction.id
        else {
            throw SymbolizationError.unknownZilProperty(zil)
        }

        return .statement(
            code: { _ in
                code
            },
            type: .direction,
            category: .properties
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
        try Factories.Quote(
            [token],
            with: &localVariables,
            mode: mode
        ).process()
    }

    /// Translates a Zil
    /// [Segment](https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#77-segments-1)
    /// token into a Quelbo ``Symbol``.
    ///
    /// - Parameter segment: The segmented Zil element.
    ///
    /// - Returns: A ``Symbol`` representation of a Zil segment.
    func symbolizeSegment(_ token: Token) throws -> Symbol {
        try Factories.Segment([token], with: &localVariables).process()
    }

    /// Translates a Zil
    /// ["# notation"](https://mdl-language.readthedocs.io/en/latest/06-data-variables/#634-chtype-1)
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
            return .literal(Int8(value))
        case "DECL":
            guard case .list(let tokens) = siblings.shift() else {
                throw SymbolizationError.missingDeclarationValue(siblings)
            }
            return try Factories.DeclareType(tokens, with: &localVariables).process()
//        case "SPLICE":
//            return .statement(code: "SPLICE (not yet implemented)")
        default:
            throw SymbolizationError.unknownType(type)
        }
    }

//    /// Translates a Zil
//    /// [Vector](https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#722-vector-1)
//    /// token into a ``Symbol``.
//    ///
//    /// - Parameter vectorTokens: A `Token` array consisting of the Zil vector elements.
//    ///
//    /// - Returns: A ``Symbol`` representation of the Zil vector.
//    func symbolizeVector(_ vectorTokens: [Token]) throws -> Symbol {
//        try Factories.Vector(vectorTokens, with: &localVariables).process()
//    }
}

// MARK: - Errors

extension Factory {
    enum SymbolizationError: Swift.Error {
        case invalidZilForm([Token])
        case missingDeclarationValue([Token])
        case noRoutineOrDefinition([Token])
        case singleTokenSymbolizationFailed(Token)
        case unknownLocal(String)
        case unknownType(String)
        case unknownZilProperty(String)
    }
}
