//
//  SymbolFactory.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

/// A base class for symbol factories whose job is to translate a parsed ``Token`` array into a
/// ``Symbol`` representation of a Zil code element.
class SymbolFactory {
    /// An array of ``Token`` values parsed from Zil source code.
    let tokens: [Token]

    /// An array of ``Symbol`` values processed from ``tokens``.
    var symbols: [Symbol] = []

    /// <#Description#>
    var isMutable: Bool = true

    required init(_ tokens: [Token]) throws {
        self.tokens = tokens
        try processTokens()
    }

    /// The Zil directives that correspond to this symbol factory.
    class var zilNames: [String] { [] }

    /// The number and types of parameters required by this symbol factory.
    var parameters: Parameters {
        .any
    }

    /// The return value type for the ``Symbol`` produced by this symbol factory.
    var returnType: Symbol.DataType {
        .unknown
    }

    /// Processes the ``tokens`` array into a ``Symbol`` array.
    ///
    /// `processTokens()` is called during initialization. Factories with special symbol processing
    /// requirements can override this method.
    ///
    /// - Returns: A `Symbol` array processed from the `tokens` array.
    ///
    /// - Throws: When the `tokens` array cannot be symbolized.
    func processTokens() throws {
        self.symbols = try symbolize(tokens)
    }

    /// Processes the factory ``symbols`` into a single ``Symbol`` representing a piece of Zil code.
    ///
    /// - Returns: A `Symbol` representing a piece of Zil code.
    ///
    /// - Throws: When the `symbols` array cannot be processed.
    func process() throws -> Symbol {
        fatalError("Implemented in subclasses")
    }

    /// Safely returns the ``Symbol`` at the specified index of the ``symbols`` array.
    ///
    /// - Parameter index: The array index to look up a `Symbol`.
    ///
    /// - Returns: The `Symbol` at the specified index in `symbols`.
    ///
    /// - Throws: When the specified index is out of range.
    func symbol(_ index: Int) throws -> Symbol {
        guard symbols.count > index else {
            throw FactoryError.outOfRangeSymbolIndex(index, symbols)
        }
        return symbols[index]
    }
}

/// Subclasses of `ZilFactory` are factories for symbols used outside of Zil Routines.
///
/// See [MDL built-ins and ZIL library](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2et92p0)
/// in the _ZILF Reference Guide_ for comprehensive documentation.
class ZilFactory: SymbolFactory {}

/// Subclasses of `ZMachineFactory` are factories for symbols used within Zil Routines.
///
/// See [Z-code built-ins](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1j4nfs6)
/// in the _ZILF Reference Guide_ for comprehensive documentation.
class ZMachineFactory: SymbolFactory {}

// MARK: - SymbolFactory.Parameters

extension SymbolFactory {
    enum Parameters: Equatable {
        case zero
        case one(Symbol.DataType)
        case oneOrMore(Symbol.DataType)
        case two(Symbol.DataType, Symbol.DataType)
        case twoOrMore(Symbol.DataType)
        case three(Symbol.DataType, Symbol.DataType, Symbol.DataType)
        case any

        var range: ClosedRange<Int> {
            switch self {
                case .zero:      return 0...0
                case .one:       return 1...1
                case .oneOrMore: return 1...Int.max
                case .two:       return 2...2
                case .twoOrMore: return 2...Int.max
                case .three:     return 3...3
                case .any:       return 0...Int.max
            }
        }

        func type(at index: Int) throws -> Symbol.DataType {
            switch self {
                case .zero:
                    throw FactoryError.invalidTypeLookup(at: index)
                case let .one(type):
                    switch index {
                        case 0:  return type
                        default: throw FactoryError.invalidTypeLookup(at: index)
                    }
                case let .oneOrMore(type):
                    return type
                case let .two(firstType, secondType):
                    switch index {
                        case 0:  return firstType
                        case 1:  return secondType
                        default: throw FactoryError.invalidTypeLookup(at: index)
                    }
                case let .twoOrMore(type):
                    return type
                case let .three(firstType, secondType, thirdType):
                    switch index {
                        case 0:  return firstType
                        case 1:  return secondType
                        case 2:  return thirdType
                        default: throw FactoryError.invalidTypeLookup(at: index)
                    }
                case .any:
                    return .unknown
            }
        }
    }
}

// MARK: - Symbolize methods

extension SymbolFactory {
    /// Translates a ``Token`` array into a ``Symbol`` array.
    ///
    /// - Parameters:
    ///   - tokens: A ``Token`` array to translate into symbols.
    ///   - validateParamCount: Whether to validate the parameter count. This should occur at the
    ///                         root level of the symbolization process, but should not occur when
    ///                         symbolizing and validating child tokens.
    ///
    /// - Returns: A ``Symbol`` array corresponding to the translated tokens.
    ///
    /// - Throws: When token translation fails.
    func symbolize(
        _ tokens: [Token],
        validateParamCount: Bool = true
    ) throws -> [Symbol] {
        var index = 0
        var symbols = try tokens.map { (token: Token) -> Symbol in
            defer {
                index += 1
            }
            switch token {
                case .atom(let string):
                    return try symbolizeAtom(string, at: index)
                case .bool(let bool):
                    return Symbol("\(bool)", type: .bool)
                case .commented(let token):
                    index -= 1
                    return Symbol("/* \(token.value) */", type: .comment)
                case .decimal(let int):
                    return Symbol("\(int)", type: .int)
                case .form(let tokens):
                    return try symbolizeForm(tokens)
                case .list(let tokens):
                    return try symbolizeList(tokens)
                case .quoted(let token):
                    index -= 1
                    return Symbol("/* \(token.value) */", type: .comment)
                case .string(let string):
                    return Symbol(string.quoted(), type: .string)
            }
        }
        symbols = try validate(symbols, validateParamCount: validateParamCount)

        return symbols
    }

    /// Translates an atom ``Token`` into a ``Symbol``.
    ///
    /// If the atom is a global variable, `symbolizeAtom` tries to look up and return its defined
    /// symbol. This throws if the global variable has not been defined yet.
    ///
    /// `symbolizeAtom` also performs lookups
    ///
    /// - Parameter zil: The original Zil atom.
    ///
    /// - Returns: A ``Symbol`` representation of the Zil atom.
    ///
    /// - Throws: When the `atom` is a global and the global has not (yet) been defined.
    func symbolizeAtom(_ zil: String, at index: Int) throws -> Symbol {
        guard !zil.hasPrefix("!\\") else {
            var character = zil
            character.removeFirst(2)
            return Symbol(character.quoted(), type: .string)
        }
        let name = zil.lowerCamelCase
        if zil.hasPrefix(".") {
            return Symbol(name, type: try parameters.type(at: index))
        }
        //        if zil.hasPrefix(",") {
        //            return try Game.find(name)
        //        }
        if let defined = try? Game.find(name) {
            return defined
        }

        return Symbol(name, type: try parameters.type(at: index))
    }

    /// Translates a Zil form ``Token`` into a ``Symbol``.
    ///
    /// - Parameter formTokens: A `Token` array consisting of the Zil form elements.
    ///
    /// - Returns: A ``Symbol`` representation of the Zil form.
    ///
    /// - Throws: When the Zil `form` lacks an opening atom.
    func symbolizeForm(_ formTokens: [Token]) throws -> Symbol {
        var tokens = formTokens
        guard case .atom(let zil) = tokens.shift() else {
            throw FactoryError.invalidZilForm(tokens)
        }
        let factory: SymbolFactory
        if let found = try Game.zMachineSymbolFactories.find(zil)?.init(tokens) {
            factory = found
        } else {
            factory = try Factories.RoutineCall(formTokens)
        }
        let symbol = try factory.process()
        self.isMutable = factory.isMutable
        return symbol
    }

    /// Translates a Zil list ``Token`` into a ``Symbol``.
    ///
    /// - Parameter listTokens: A `Token` array consisting of the Zil list elements.
    ///
    /// - Returns: A ``Symbol`` representation of the Zil list.
    ///
    /// - Throws: When the Zil `form` lacks an opening atom.
    func symbolizeList(_ listTokens: [Token]) throws -> Symbol {
        guard !listTokens.isEmpty else {
            return Symbol("<EmptyList>", type: .list)
        }
        let listSymbols = try symbolize(listTokens, validateParamCount: false)
        return Symbol(
            "<List>",
            type: .list,
            children: try validate(listSymbols, validateParamCount: false)
        )
    }
}

// MARK: - Symbol validation

extension SymbolFactory {
    func validate(
        _ symbols: [Symbol],
        validateParamCount: Bool = true
    ) throws -> [Symbol] {
        if validateParamCount {
            let nonCommentParams = symbols.filter { $0.type != .comment }
            guard parameters.range.contains(nonCommentParams.count) else {
                throw FactoryError.invalidParameterCount(
                    nonCommentParams.count,
                    expected: parameters.range,
                    in: nonCommentParams
                )
            }
        }

        var index = 0
        let typedSymbols: [Symbol] = try symbols.compactMap { symbol in
            defer {
                if symbol.type != .comment { index += 1 }
            }
            return try assignType(
                of: symbol,
                to: parameters.type(at: index),
                siblings: symbols
            )
        }
        switch parameters {
            case .one, .oneOrMore, .twoOrMore:
                _ = try typedSymbols.commonType()
            default: break
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
//        print("// 🍅 \(symbol): (\(symbol.type.isLiteral), \(declaredType.isLiteral)) [\(declaredType)]")
        if declaredType == .tableElement {
            return try assignTableElementType(on: symbol)
        }

        switch (symbol.type.isLiteral, declaredType.isLiteral) {
            case (true, true):
                if symbol.type == declaredType {
                    return symbol
                }
            case (true, false):
                if declaredType.acceptsLiteral {
                    return symbol
                }
            case (false, true):
                return symbol.with(declaredType)
            case (false, false):
                if symbol.type.isContainer {
                    return symbol
                }
                return symbol.with(try siblings.commonType())
        }

        throw FactoryError.invalidType(symbol, expected: declaredType)
    }

    func assignTableElementType(on symbol: Symbol) throws -> Symbol? {
        switch symbol.type {
            case .array:
                return symbol
                    .with(code: """
                        .table([
                        \(symbol.children.codeValues(separator: ",", lineBreaks: 1).indented()),
                        ])
                        """)
                    .with(.tableElement)
            case .bool:
                return symbol
                    .with(code: ".bool(\(symbol))")
                    .with(.tableElement)
            case .comment:
                return symbol
                    .with(code: "// \(symbol)")
                    .with(.tableElement)
            case .int:
                return symbol
                    .with(code: ".int(\(symbol))")
                    .with(.tableElement)
            case .list:
                guard symbol.children.first?.id == "pure" else {
                    throw FactoryError.unexpectedTableElement(symbol)
                }
                isMutable = false
                return nil
            case .object:
                if let category = symbol.category, category == .rooms {
                    return symbol
                        .with(code: ".room(\(symbol))")
                        .with(.tableElement)
                } else {
                    return symbol
                        .with(code: ".object(\(symbol))")
                        .with(.tableElement)
                }
            case .string:
                return symbol
                    .with(code: ".string(\(symbol))")
                    .with(.tableElement)
            case .tableElement:
                return symbol
                    .with(code: ".table(\(symbol))")
                    .with(.tableElement)
            default:
                throw FactoryError.unexpectedTableElement(symbol)
        }
    }
}

// MARK: - Factories namespace

/// Namespace for symbol factories that translate a ``Token`` array to a ``Symbol`` array.
enum Factories {}

// MARK: - FactoryError

enum FactoryError: Swift.Error {
    case foundMultipleMatchingFactories(zil: String, matches: [SymbolFactory.Type])
    case incorrectParameters([Token], expected: String)
    case indeterminateTypes([Token], types: [Symbol.DataType])
    case invalidConditionList([Token])
    case invalidConditionPredicate([Symbol])
    case invalidConditionExpression([Symbol])
    case invalidParameter([Symbol])
    case invalidParameterCount(Int, expected: ClosedRange<Int>, in: [Symbol])
    case invalidType(Symbol, expected: Symbol.DataType)
    case invalidTypeLookup(at: Int)
    case invalidValue(Symbol)
    case invalidZilForm([Token])
    case outOfRangeSymbolIndex(Int, [Symbol])
    case missingName([Token])
    case missingParameter(Symbol)
    case missingParameters([Token])
    case missingTypeToken([Token])
    case missingValue([Token])
    case unexpectedParameter(Symbol)
    case unconsumedTokens([Token])
    case unexpectedTableElement(Symbol)
    case unexpectedTypeParameter([Token], expected: Symbol.DataType, found: [Symbol.DataType])
    case unknownType([Token])
    case unknownZMachineFunction(zil: String)
    case unknownZilFunction(zil: String)
}

// MARK: - Special Token handlers

extension SymbolFactory {
    /// Scans through a ``Token`` array until it finds an atom, then returns a special ``Symbol``
    /// representation, where `id` contains the original Zil name, and `code` contains its Swift
    /// translation.
    ///
    /// The `Token` array is mutated in the course of the search, removing any elements up to and
    /// including the target atom.
    ///
    /// - Parameter tokens: A `Token` array to search.
    ///
    /// - Returns: A `Symbol` translation of the found atom.
    ///
    /// - Throws: When no atom is found.
    func findNameSymbol(in tokens: inout [Token]) throws -> Symbol {
        let original = tokens
        while !tokens.isEmpty {
            guard case .atom(let name) = tokens.shift() else {
                continue
            }
            return Symbol(id: name, code: name.lowerCamelCase)
        }
        throw FactoryError.missingName(original)
    }

    /// Scans through a ``Token`` array until it finds a parameter list, then returns a translated
    /// ``Symbol`` array.
    ///
    /// The `Token` array is mutated in the course of the search, removing any elements up to and
    /// including the target list.
    ///
    /// - Parameter tokens: A `Token` array to search.
    ///
    /// - Returns: An array of `Symbol` translations of the list tokens.
    ///
    /// - Throws: When no list is found, or token symbolization fails.
    func findParameterSymbols(in tokens: inout [Token]) throws -> [Symbol] {
        let original = tokens
        while !tokens.isEmpty {
            guard case .list(let params) = tokens.shift() else {
                continue
            }
            return try symbolize(params)
        }
        throw FactoryError.missingParameters(original)
    }

//    /// <#Description#>
//    ///
//    /// - Parameter tokens: <#tokens description#>
//    ///
//    /// - Returns: <#description#>
//    ///
//    /// - Throws:
//    func findValueSymbol(
//        in tokens: inout [Token],
//        requireLiteral: Bool = false
//    ) throws -> Symbol {
//        var symbols = try symbolize(tokens)
//        var valueSymbol: Symbol?
//        while let value = symbols.shift() {
//            if requireLiteral && !value.type.isLiteral {
//                continue
//            } else if !value.type.hasReturnValue {
//                continue
//            }
//            guard valueSymbol == nil else {
//                throw FactoryError.unconsumedTokens(tokens)
//            }
//            valueSymbol = value
//        }
//        guard let valueSymbol = valueSymbol else {
//            throw FactoryError.missingValue(tokens)
//        }
//        return valueSymbol
//    }
}

// MARK: - Array where Element == SymbolFactory

extension Array where Element == SymbolFactory.Type {
    /// Finds the symbol that corresponds to the
    ///
    /// - Parameter zil: The Zil directive to search for in an array of symbol factories.
    ///
    /// - Returns: A matching symbol factory.
    ///
    /// - Throws: When either zero or multiple symbol factories are found matching the specified
    ///           Zil directive.
    func find(_ zil: String) throws -> SymbolFactory.Type? {
        let matches = filter { $0.zilNames.contains(zil) }
        switch matches.count {
            case 0:
                return nil
            case 1:
                return matches[0]
            default:
                throw FactoryError.foundMultipleMatchingFactories(zil: zil, matches: matches)
        }
    }
}

// MARK: - Equatable

extension SymbolFactory: Equatable {
    static func == (lhs: SymbolFactory, rhs: SymbolFactory) -> Bool {
        type(of: lhs) == type(of: rhs)
    }
}
