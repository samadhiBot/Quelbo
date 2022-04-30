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

    /// Whether the symbol represents a literal value.
    let literal: Bool

    /// The symbol's ``Symbol/Category-swift.enum``.
    let category: Category?

    /// Any child symbols belonging to a complex symbol.
    let children: [Symbol]

    /// Any additional information required for symbol processing.
    let meta: [String: String]

    init(
        id: String,
        code: String? = nil,
        type: DataType = .unknown,
        literal: Bool = false,
        category: Category? = nil,
        children: [Symbol] = [],
        meta: [String: String] = [:]
    ) {
        self.id = id
        self.code = code?.rightTrimmed ?? id
        self.type = type
        self.literal = literal
        self.category = category
        self.children = children
        self.meta = meta
    }

    init(
        _ code: String,
        type: DataType = .unknown,
        literal: Bool = false,
        category: Category? = nil,
        children: [Symbol] = [],
        meta: [String: String] = [:]
    ) {
        self.id = code.rightTrimmed
        self.code = code.rightTrimmed
        self.type = type
        self.literal = literal
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

    /// Whether the symbol represents a variable that mutates somewhere in the specified symbols.
    func isMutating(in symbols: [Symbol]) -> Bool? {
        for symbol in symbols {
            if symbol.id == id && symbol.meta["mutating"] == "true" {
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

    /// Returns the symbol with metadata to indicate that mutating occurs.
    var mutating: Symbol {
        withMeta(key: "mutating", value: "true")
    }

    /// Returns the symbol with one or more specified properties updated.
    ///
    /// - Parameters:
    ///   - id: The symbol's unique identifier.
    ///   - code: The Swift translation of a piece of Zil code.
    ///   - type: The symbol data type for the code.
    ///   - literal: Whether the symbol represents a literal value.
    ///   - category: The symbol's category.
    ///   - children: Any child symbols belonging to a complex symbol.
    ///   - meta: Any additional information required for symbol processing.
    ///
    /// - Returns: The symbol with any specified properties updated.
    func with(
        id: String? = nil,
        code: String? = nil,
        type: DataType? = nil,
        literal: Bool? = nil,
        category: Category? = nil,
        children: [Symbol]? = nil,
        meta: [String: String]? = nil
    ) -> Symbol {
        Symbol(
            id: id ?? self.id,
            code: code ?? self.code,
            type: type ?? self.type,
            literal: literal ?? self.literal,
            category: category ?? self.category,
            children: children ?? self.children,
            meta: meta ?? self.meta
        )
    }

    /// Returns the symbol with the specified metadata applied.
    ///
    /// - Parameters:
    ///   - key: The metadata key to apply.
    ///   - value: The value to assign to the specified metadata key.
    func withMeta(key: String, value: String) -> Symbol {
        var newMeta = meta
        newMeta[key] = value
        return with(meta: newMeta)
    }
}

// MARK: - Symbol.Category

extension Symbol {
    /// The set of ``Symbol`` categories.
    ///
    /// Categories are used to distinguish different kinds of symbols, allowing them to be grouped
    /// together appropriately in the game translation.
    enum Category: String {
        case constants
        case directions
        case globals
        case objects
        case properties
        case rooms
        case routines
    }
}

// MARK: - Symbol.DataType

extension Symbol {
    /// The set of data types associated with symbols.
    ///
    enum DataType: Hashable {
        indirect case array(DataType)
        case bool
        case comment
        case direction
        case int
        case list
        case object
        case property
        case routine
        case string
        case tableElement
        case thing
        case unknown
        case void

        /// Whether a literal value can represent the data type.
        var acceptsLiteral: Bool {
            switch self {
            case .object, .property: return false
            default: return true
            }
        }

        /// Whether the data type has a known return value type.
        var hasKnownReturnValue: Bool {
            switch self {
            case .comment, .list, .property, .unknown: return false
            default: return true
            }
        }

        /// Whether the data type has a return value.
        var hasReturnValue: Bool {
            switch self {
            case .comment, .property, .unknown, .void: return false
            default: return true
            }
        }

        /// Whether the data type is a container.
        var isContainer: Bool {
            switch self {
            case .comment, .list, .object: return true
            default: return false
            }
        }

        /// Whether the data type is known.
        var isKnown: Bool {
            switch self {
            case .array(let dataType): return dataType.isKnown
            case .object, .property, .unknown: return false
            default: return true
            }
        }

        /// Whether the data type is a literal value type.
        var isLiteral: Bool {
            switch self {
            case .array(let dataType): return dataType.isLiteral
            case .bool, .direction, .int, .string, .tableElement: return true
            default: return false
            }
        }
    }
}

extension Symbol.DataType: CustomStringConvertible {
    var description: String {
        switch self {
        case .array(let type): return "[\(type)]"
        case .bool:            return "Bool"
        case .comment:         return "<Comment>"
        case .direction:       return "Direction"
        case .int:             return "Int"
        case .list:            return "<List>"
        case .object:          return "Object"
        case .property:        return "<Property>"
        case .routine:         return "Routine"
        case .string:          return "String"
        case .thing:           return "Thing"
        case .tableElement:    return "TableElement"
        case .unknown:         return "<Unknown>"
        case .void:            return "Void"
        }
    }
}

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

extension Array where Element == Symbol {
    /// A
    ///
    /// - Parameter emptyLineAfter: Whether to leave an empty line after each code value.
    ///
    /// - Returns: A string containing the sorted code values for an array of symbols.


    /// Returns a formatted string containing the ``Symbol/code`` values for a ``Symbol`` array.
    ///
    /// - Parameters:
    ///   - separator: A string to place between each of the code elements.
    ///   - lineBreaks: The number of line breaks to place between each of the code elements.
    ///   - sorted: Whether to sort the code elements.
    ///
    /// - Returns: A formatted string containing the code values contained in the symbol array.
    func codeValues(
        separator: String = "",
        lineBreaks: Int = 0,
        sorted: Bool = false
    ) -> String {
        var separator = separator.rightTrimmed
        if lineBreaks == 0 {
            separator.append(" ")
        }
        for _ in 0..<lineBreaks {
            separator.append("\n")
        }
        if sorted {
            return self.sorted { $0.id < $1.id }
                .compactMap { $0.code.isEmpty ? nil : $0.code }
                .joined(separator: separator)
        } else {
            return self.compactMap { $0.code.isEmpty ? nil : $0.code }
                .joined(separator: separator)
        }
    }

    /// Returns a string representing an array of code values represented in the ``Symbol`` array.
    var code: String {
        guard !isEmpty else {
            return "[]"
        }
        let code = codeValues(separator: ",", lineBreaks: 1)
        if code.contains("\n") {
            return "[\n\(code.indented)\n]"
        } else {
            return "[\(code)]"
        }
    }

    /// Finds the common type among the symbols in the array.
    ///
    /// Ignores atoms with ``Symbol/DataType/unknown`` type.
    ///
    /// - Returns: The common type among the symbols in the array.
    ///
    /// - Throws: When a common type cannot be determined. This can either occur when all types are
    ///           unknown, or when there are multiple known types that do not match.
    func commonType() throws -> Symbol.DataType {
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

        throw Symbol.Error.typeNotFound(self)
    }

    /// Deep-searches a ``Symbol`` array for a `"paramDeclarations"` metadata declaration, and
    /// returns its value if one is found.
    var deepParamDeclarations: String? {
        for symbol in self {
            if let paramDeclarations = symbol.meta["paramDeclarations"] {
                return paramDeclarations
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
            if symbol.meta["block"] == "repeatingWithoutDefaultActivation" {
                return true
            }
            if let deepRepeatingChild = symbol.children.deepRepeating {
                return deepRepeatingChild
            }
        }
        return nil
    }

    /// Deep-searches a ``Symbol`` array for an explicit `return` statement with a return value, and
    /// returns the type of the returned value if one is found.
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
}

// MARK: - Common literal symbols

extension Symbol {
    static var falseSymbol: Symbol {
        Symbol("false", type: .bool, literal: true)
    }

    static var trueSymbol: Symbol {
        Symbol("true", type: .bool, literal: true)
    }
}
