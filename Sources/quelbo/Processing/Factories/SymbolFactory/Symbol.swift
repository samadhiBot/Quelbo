//
//  Symbol.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/26/22.
//

import Foundation

/// A representation of a piece of Zil code and its Swift translation.
struct Symbol: Equatable, Identifiable {
    /// The symbol's unique identifier.
    let id: Symbol.Identifier

    /// The Swift translation of a piece of Zil code.
    let code: String

    /// The ``Symbol/DataType-swift.enum`` for the ``code``.
    let type: DataType

    /// The symbol's ``Symbol/Category-swift.enum``.
    let category: Category?

    /// Any child symbols belonging to a complex symbol.
    let children: [Symbol]

    /// Any additional information required for symbol processing.
    let meta: [MetaData]

    init(
        id: Symbol.Identifier,
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
        self.id = .id(code.rightTrimmed)
        self.code = code.rightTrimmed
        self.type = type
        self.category = category
        self.children = children
        self.meta = meta
    }
}

// MARK: - Symbol helper methods

extension Symbol {
    /// Whether the symbol's children are ``Factories/Table`` definition flags.
    var containsTableFlags: Bool {
        !children.isEmpty && children.allSatisfy {
            ["byte", "length", "lexv", "pure", "string", "word"].contains($0.code)
        }
    }

    /// Returns a description of the symbol's data type.
    var dataType: String {
        for metaData in meta {
            if case .type(let type) = metaData {
                return type
            }
        }
        return type.description
    }

    /// Whether the symbol represents an `AGAIN` statement.
    var isAgainStatement: Bool {
        self.id == .id("<Again>")
    }

    /// Whether the symbol represents a code block.
    var isCodeBlock: Bool {
        self.id == .id("<Block>")
    }

    /// Whether the symbol represents a closure.
    var isFunctionClosure: Bool {
        for metaData in meta {
            if case .type = metaData {
                return true
            }
        }
        return false
    }

    /// Whether the symbol represents a literal value.
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

    /// Whether the symbol represents a global variable with a placeholder value of unknown type.
    ///
    /// This occurs with zil declarations such as `<GLOBAL PRSO <>>`, where the `false` is
    /// ambiguous. If Quelbo discovers a different `type` through the variable's use in the code,
    /// it updates the global with the found `type`.
    var isPlaceholderGlobal: Bool {
        guard
            [.constants, .globals].contains(category),
            let committed = try? Game.find(id)
        else {
            return false
        }
        return committed.meta.contains(.maybeEmptyValue)
    }

    /// Whether the symbol represents a `RETURN` statement.
    var isReturnStatement: Bool {
        self.id == .id("<Return>")
    }

    /// Returns an unevaluated token stored by the symbol, if one exists.
    var definition: [Token] {
        for metaData in meta {
            if case .zil(let tokens) = metaData {
                return tokens
            }
        }
        return []
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
        id newID: Symbol.Identifier? = nil,
        code newCode: String? = nil,
        type newType: DataType? = nil,
        category newCategory: Category? = nil,
        children newChildren: [Symbol]? = nil,
        meta newMeta: [MetaData] = []
    ) -> Symbol {
        Symbol(
            id: newID ?? id,
            code: newCode ?? code,
            type: newType ?? type,
            category: newCategory ?? category,
            children: newChildren ?? children,
            meta: newMeta.isEmpty ? meta : meta.assigning(newMeta)
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

        /// Symbols representing evaluated functions defined by the game.
        case functions

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
        id.description
//        var desc: [String] = ["id: \(id)"]
//        if code != id.stringLiteral {
//            desc.append("code: \(code)")
//        }
//        if type != .unknown {
//            desc.append("type: \(type)")
//        }
//        if let category = category {
//            desc.append("category: \(category)")
//        }
//        if !meta.isEmpty {
//            desc.append("meta: \(meta)")
//        }
//        return "{\n\(desc.joined(separator: "\n").indented)\n}"
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
    func find(id symbolID: Symbol.Identifier) -> Symbol? {
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
        Symbol("false", type: .bool, meta: [.isLiteral, .maybeEmptyValue])
    }

    /// A literal boolean `true` symbol.
    static var trueSymbol: Symbol {
        Symbol("true", type: .bool, meta: [.isLiteral])
    }

    /// A literal integer `0` symbol.
    static var zeroSymbol: Symbol {
        Symbol("0", type: .int, meta: [.isLiteral, .maybeEmptyValue])
    }
}
