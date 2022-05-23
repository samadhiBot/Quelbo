//
//  Symbol.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/26/22.
//

import Foundation

/// A representation of a piece of Zil code and its Swift translation.
struct Symbol: Equatable {
    /// The symbol's unique identifier.
    let id: String

    /// The Swift translation of a piece of Zil code.
    let code: String

    /// The ``Symbol/DataType`` for the ``code``.
    let type: DataType

    /// The symbol's ``Symbol/Category-swift.enum``.
    let category: Category?

    /// Any child symbols belonging to a complex symbol.
    let children: [Symbol]

    /// Any additional information required for symbol processing.
    let meta: [MetaData]

    init(
        id: String,
        code: String = "",
        type: DataType = .unknown,
        category: Category? = nil,
        children: [Symbol] = [],
        meta: [MetaData] = []
    ) {
        self.id = id
        self.code = code.rightTrimmed
        self.type = type
        self.category = category
        self.children = children
        self.meta = meta
    }

    init(
        _ code: String,
        type: DataType = .unknown,
        category: Category? = nil,
        children: [Symbol] = [],
        meta: [MetaData] = []
    ) {
        self.id = code.rightTrimmed
        self.code = code.rightTrimmed
        self.type = type
        self.category = category
        self.children = children
        self.meta = meta
    }
}

// MARK: - Symbol helper methods

extension Symbol {
    /// Whether the symbol represents an `AGAIN` statement.
    var isAgainStatement: Bool {
        self.id == "<Again>"
    }

    /// Whether the symbol represents a code block.
    var isCodeBlock: Bool {
        self.id == "<Block>"
    }

    /// <#Description#>
    var isFunctionClosure: Bool {
        for metaData in meta {
            if case .type = metaData {
                return true
            }
        }
        return false
    }

    /// <#Description#>
    var isLiteral: Bool {
        for metaData in meta {
            if case .isLiteral = metaData {
                return true
            }
        }
        return false
    }

    /// Whether the symbol represents a mutating variable.
    func isMutating(in symbols: [Symbol]) -> Bool? {
        for symbol in symbols {
            if symbol.id == id && symbol.meta.contains(.mutating(true)) {
                return true
            }
            if let foundInChildren = isMutating(in: symbol.children) {
                return foundInChildren
            }
        }
        return nil
    }

    /// Whether the symbol represents a `RETURN` statement.
    var isReturnStatement: Bool {
        self.id == "<Return>"
    }

    /// <#Description#>
    var dataType: String {
        for metaData in meta {
            if case .type(let type) = metaData {
                return type
            }
        }
        return type.description
    }

    /// <#Description#>
    var unevaluated: Token? {
        for metaData in meta {
            if case .eval(let token) = metaData {
                return token
            }
        }
        return nil
    }

    /// Returns the symbol with one or more properties replaced with those specified.
    ///
    /// - Parameters:
    ///   - id: The symbol's unique identifier.
    ///   - code: The Swift translation of a piece of Zil code.
    ///   - type: The symbol data type for the code.
    ///   - category: The symbol's category.
    ///   - children: Any child symbols belonging to a complex symbol.
    ///   - meta: Any additional information required for symbol processing.
    ///
    /// - Returns: The symbol with any specified properties updated.
    func with(
        id: String? = nil,
        code: String? = nil,
        type: DataType? = nil,
        category: Category? = nil,
        children: [Symbol]? = nil,
        meta: [MetaData] = []
    ) -> Symbol {
        Symbol(
            id: id ?? self.id,
            code: code ?? self.code,
            type: type ?? self.type,
            category: category ?? self.category,
            children: children ?? self.children,
            meta: meta.isEmpty ? self.meta : self.meta.assigning(meta)
        )
    }
}

// MARK: - Symbol.Category

extension Symbol {
    /// The set of ``Symbol`` categories.
    ///
    /// Categories are used to distinguish different kinds of symbols, allowing them to be grouped
    /// together appropriately in the game translation.
    enum Category: String {
        /// Symbols representing global constant game values.
        case constants

        /// Symbols representing definitions that are evaluated to create other symbols.
        case definitions

        /// Symbols representing room exit directions.
        case directions

        /// Symbols representing object flags.
        case flags

        /// Symbols representing global game variables.
        case globals

        /// Symbols representing objects in the game.
        case objects

        /// Symbols representing object properties.
        case properties

        /// Symbols representing rooms (i.e. locations) in the game.
        case rooms

        /// Symbols representing routines defined by the game.
        case routines

        /// Symbols representing syntax declarations specified by the game.
        case syntax
    }
}

// MARK: - Symbol.Error

extension Symbol {
    enum Error: Swift.Error, Equatable {
        case typeMismatch(Symbol, expected: Symbol.DataType)
        case typeNotFound([Symbol])
        case unexpectedType([Symbol], expected: Symbol.DataType)
    }
}

// MARK: - Conformances

extension Symbol: Comparable {
    static func < (lhs: Symbol, rhs: Symbol) -> Bool {
        lhs.id < rhs.id
    }
}

extension Symbol: CustomStringConvertible {
    var description: String {
        code
    }
}

// MARK: - Array where Element == Symbol

extension Symbol {
    /// Display options for use with the `codeValues` method.
    enum CodeValuesDisplayOption {
        /// Values to be comma-separated with a line break after each value.
        case commaLineBreakSeparated

        /// Values to be comma-separated.
        case commaSeparated

        /// Values to be comma-separated.
        case commaSeparatedNoTrailingComma

        /// Values to be comma-separated with a double line break after each value.
        case doubleLineBreak

        /// The set of values to be indented.
        case indented

        /// Values to be separated by the specified string.
        case separator(String)

        /// Values to separated by a line break after each value.
        case singleLineBreak
    }
}

extension Array where Element == Symbol {
    /// Returns a formatted string containing the ``Symbol/code`` values for a ``Symbol`` array.
    ///
    /// - Parameter displayOptions: One or more ``Symbol/CodeValuesDisplayOption`` values that
    ///                             specify how to separate and display the code values.
    ///
    /// - Returns: A formatted string containing the code values contained in the symbol array.
    func codeValues(_ displayOptions: Symbol.CodeValuesDisplayOption...) -> String {
        var addBlock = false
        var indented = false
        var lineBreaks = 0
        var noTrailingComma = false
        var separator = ""

        displayOptions.forEach { option in
            switch option {
            case .commaLineBreakSeparated:
                indented = true
                lineBreaks = 1
                separator = ","
            case .commaSeparated:
                separator = ","
            case .commaSeparatedNoTrailingComma:
                noTrailingComma = true
                separator = ","
            case .doubleLineBreak:
                lineBreaks = 2
            case .indented:
                indented = true
            case .separator(let string):
                separator = string.rightTrimmed
            case .singleLineBreak:
                lineBreaks = 1
            }
        }
        let codeValues = compactMap {
            $0.code.isEmpty ? nil : $0.code
        }
        if lineBreaks == 0 && separator == "," {
            let code = codeValues.joined(separator: separator)
            if code.count > 20 || code.contains("\n") {
                addBlock = true
                lineBreaks = 1
                indented = true
            }
        }
        if lineBreaks == 0 {
            separator.append(" ")
        }
        for _ in 0..<lineBreaks {
            separator.append("\n")
        }
        var values = codeValues.joined(separator: separator)
        if indented {
            values = values.indented.rightTrimmed
        }
        if addBlock {
            values = "\n\(values)\(noTrailingComma ? "\n" : separator)"
        }
        return values
    }

    /// Finds the common type among the symbols in the array.
    ///
    /// Ignores atoms with ``Symbol/DataType/unknown`` type.
    ///
    /// - Returns: The common type among the symbols in the array.
    ///
    /// - Throws: When a common type cannot be determined. This can either occur when all types are
    ///           unknown, or when there are multiple known types that do not match.
    func commonType(_ strict: Bool = true) throws -> Symbol.DataType {
        let types = map { $0.type }.unique
        switch types.count {
            case 0:  throw Symbol.Error.typeNotFound(self)
            case 1:  return types[0]
            default: break
        }

        let literals = types.filter { $0.isLiteral }
        switch literals.count {
            case 0:  break
            case 1:  return literals[0]
            default: throw Symbol.Error.typeNotFound(self)
        }

        let knowns = types.filter { $0.isKnown }
        switch knowns.count {
            case 1:  return knowns[0]
            default: break
        }

        if strict {
            throw Symbol.Error.typeNotFound(self)
        } else {
            return .unknown
        }
    }

    /// Deep-searches a ``Symbol`` array for a `"paramDeclarations"` metadata declaration, and
    /// returns its value if one is found.
    var deepParamDeclarations: String? {
        for symbol in self {
            for metaData in symbol.meta {
                if case .paramDeclarations(let params) = metaData {
                    return params
                }
            }
            if let paramDeclarations = symbol.children.deepParamDeclarations {
                return paramDeclarations
            }
        }
        return nil
    }

    /// Deep-searches a ``Symbol`` array for a `"block"` metadata declaration with
    /// `"repeatingWithoutDefaultActivation"` value, and returns `true` if one is found.
    var deepRepeating: Bool? {
        for symbol in self {
            if symbol.meta.contains(.blockType(.repeatingWithoutDefaultActivation)) {
                return true
            }
            if let deepRepeatingChild = symbol.children.deepRepeating {
                return deepRepeatingChild
            }
        }
        return nil
    }

    /// Deep-searches a ``Symbol`` array for an explicit `return` statement with a return value,
    /// and returns the type of the returned value if one is found.
    var deepReturnDataType: Symbol.DataType? {
        for symbol in self {
            if symbol.isReturnStatement {
                return symbol.children.first?.type
            }
            if let type = symbol.children.deepReturnDataType {
                return type
            }
        }
        return nil
    }

    /// Searches the array to find a ``Symbol`` with the specified `id`.
    ///
    /// The recursive search inspects each `Symbol` and each symbol's `children`, until it finds a
    /// match, which it returns.
    ///
    /// - Parameter id: A unique `Symbol` identifier.
    ///
    /// - Returns: A `Symbol` with the specified `id`, if one exists within the array.
    func find(id symbolID: String) -> Symbol? {
        for symbol in self {
            if symbolID == symbol.id {
                return symbol
            } else if let childSymbol = symbol.children.find(id: symbolID) {
                return childSymbol
            }
        }
        return nil
    }

    /// Returns the ``Symbol`` array with quotes applied to the code values of any elements with
    /// type ``Symbol/DataType/string``.
    var quoted: [Symbol] {
        map { symbol in
            guard symbol.type == .string else {
                return symbol
            }
            return symbol.with(code: symbol.code.quoted)
        }
    }

    /// Returns the ``Symbol`` array sorted by element ``Symbol/id``.
    var sorted: [Symbol] {
        sorted {
            if $0.category == .flags {
                return $0.code < $1.code
            } else {
                return $0.id < $1.id
            }
        }
    }
}

// MARK: - Common literal symbols

extension Symbol {
    /// A literal boolean `false` symbol.
    static var falseSymbol: Symbol {
        Symbol("false", type: .bool, meta: [.isLiteral])
    }

    /// A literal boolean `true` symbol.
    static var trueSymbol: Symbol {
        Symbol("true", type: .bool, meta: [.isLiteral])
    }
}
