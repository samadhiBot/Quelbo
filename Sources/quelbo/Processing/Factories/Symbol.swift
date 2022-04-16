//
//  Symbol.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/26/22.
//

import Foundation

/// A representation of a piece of Zil code and its Swift translation.
struct Symbol: Equatable {
    /// A symbol's unique identifier.
    let id: String

    /// The Swift translation of a piece of Zil code.
    let code: String

    /// The ``Symbol/DataType`` for the ``code``.
    let type: DataType

    /// The symbol's ``Symbol/Category-swift.enum``.
    let category: Category?

    /// Any child symbols belonging to a complex symbol.
    let children: [Symbol]

    init(
        id: String,
        code: String? = nil,
        type: DataType = .unknown,
        category: Category? = nil,
        children: [Symbol] = []
    ) {
        self.id = id
        self.code = code ?? id
        self.type = type
        self.category = category
        self.children = children
    }

    init(
        _ code: String,
        type: DataType = .unknown,
        category: Category? = nil,
        children: [Symbol] = []
    ) {
        self.id = code
        self.code = code
        self.type = type
        self.category = category
        self.children = children
    }

    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Returns: <#description#>
    func with(id: String) -> Symbol {
        Symbol(
            id: id,
            code: code,
            type: type,
            category: category,
            children: children
        )
    }

    /// <#Description#>
    /// - Parameter code: <#code description#>
    /// - Returns: <#description#>
    func with(code: String) -> Symbol {
        Symbol(
            id: id,
            code: code,
            type: type,
            category: category,
            children: children
        )
    }

    /// <#Description#>
    /// - Parameter type: <#type description#>
    /// - Returns: <#description#>
    func with(_ type: DataType) -> Symbol {
        Symbol(
            id: id,
            code: code,
            type: type,
            category: category,
            children: children
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

        var hasReturnValue: Bool {
            switch self {
                case .comment, .unknown, .void: return false
                default: return true
            }
        }

        var acceptsLiteral: Bool {
            switch self {
                case .object, .property: return false
                default: return true
            }
        }

        var isContainer: Bool {
            switch self {
                case .comment, .list, .object: return true
                default: return false
            }
        }

        var isKnown: Bool {
            switch self {
                case .array(let dataType): return dataType.isKnown
                case .object, .property, .unknown: return false
                default: return true
            }
        }

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
    /// A string containing the sorted ``Symbol/code`` values for an array of symbols, with or
    /// without an empty line after each value.
    ///
    /// - Parameter emptyLineAfter: Whether to leave an empty line after each code value.
    ///
    /// - Returns: A string containing the sorted code values for an array of symbols.
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
        let codeValues = map { $0.code }
        if sorted {
            return codeValues.sorted().joined(separator: separator)
        } else {
            return codeValues.joined(separator: separator)
        }
    }

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

    /// <#Description#>
    var quoted: [Symbol] {
        map { symbol in
            guard symbol.type == .string else {
                return symbol
            }
            return symbol.with(code: symbol.code.quoted)
        }
    }
}
