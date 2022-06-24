//
//  Symbol.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/26/22.
//

import Foundation

extension Symbol {
    /// The set of data types associated with symbols.
    ///
    enum DataType: Hashable {
        case bool
        case comment
        case direction
        case int
        case int16
        case int32
        case int8
        case object
        case routine
        case string
        case table
        case thing
        case unknown
        case void
        case zilElement
        indirect case array(DataType)
        indirect case optional(DataType)
        indirect case property(DataType)
        indirect case variable(DataType)
    }
}

// MARK: - Helper methods

extension Symbol.DataType {
    /// Whether the data type can be a literal value.
    var acceptsLiteral: Bool {
        switch self {
        case .object, .property, .table, .variable: return false
        default: return true
        }
    }

    /// <#Description#>
    var emptyMeta: Set<Symbol.MetaData> {
        switch self {
        case .bool, .int: return [.isLiteral, .maybeEmptyValue]
        default: return []
        }
    }

    /// An empty placeholder value for the data type.
    var emptyValueAssignment: String {
        switch self {
        case .bool: return " = false"
        case .comment: break
        case .direction, .object, .routine, .table, .thing: return "? = nil"
        case .int, .int8, .int16, .int32: return " = 0"
        case .optional, .property: return " = nil"
        case .string: return " = \"\""
        case .unknown: break
        case .void: break
        case .array: return " = []"
        case .variable(let type): return type.emptyValueAssignment
        case .zilElement: return " = .none"
        }
        return " = <\(self)>"
    }

    /// An empty placeholder type for the data type.
    var emptyValueType: Self {
        switch self {
        case .direction, .object, .routine, .table, .thing: return .optional(self)
        case .property(let type): return type.emptyValueType
        case .variable(let type): return type.emptyValueType
        default: return self
        }
    }

    /// Whether the data type has a known return value type.
    var hasKnownReturnValue: Bool {
        switch self {
        case .array(let type): return type.hasKnownReturnValue
        case .optional(let type): return type.hasKnownReturnValue
        case .property(let type): return type.hasKnownReturnValue
        case .unknown: return false
        case .variable(let type): return type.hasKnownReturnValue
        default: return true
        }
    }

    /// Whether the data type has a return value.
    var hasReturnValue: Bool {
        switch self {
        case .comment, .unknown, .void: return false
        default: return true
        }
    }

    /// Whether the data type is a literal value type.
    var isLiteral: Bool {
        switch self {
        case .array(let type): return type.isLiteral
        case .bool, .direction, .int, .int8, .int16, .int32, .string: return true
        case .optional(let type): return type.isLiteral
        default: return false
        }
    }

    /// Whether the data type is an optional value type.
    var isOptional: Bool {
        if case .optional = self {
            return true
        }
        return false
    }

    /// Whether the data type is a property value type.
    var isProperty: Bool {
        if case .property = self {
            return true
        }
        return false
    }

    /// Whether the data type is unambiguous, i.e. is known and homogeneous.
    var isUnambiguous: Bool {
        switch self {
        case .array(let type): return type.isUnambiguous
        case .optional(let type): return type.isUnambiguous
        case .property(let type): return type.isUnambiguous
        case .unknown, .zilElement: return false
        case .variable(let type): return type.isUnambiguous
        default: return true
        }
    }

    /// Whether the data type is ``Symbol/DataType-swift.enum/unknown``.
    var isUnknown: Bool {
        switch self {
        case .array(let type): return type.isUnknown
        case .optional(let type): return type.isUnknown
        case .property(let type): return type.isUnknown
        case .unknown: return true
        case .variable(let type): return type.isUnknown
        default: return false
        }
    }

    /// Whether the data type should replace that in the specified symbol when a type conflict
    /// occurs.
    ///
    /// - Parameter symbol: A symbol with a conflicting type.
    ///
    /// - Returns: Whether the data type should supersede the one in the specified symbol.
    func shouldReplaceType(in symbol: Symbol) -> Bool {
        switch (self, symbol.type) {
        case (.unknown, _):
            return false
        case (_, .zilElement):
            return true
        case (.bool, .int):
            return true
        case (.int, _),
             (.object, _),
             (.string, _),
             (.table, _):
            return symbol.meta.contains(.maybeEmptyValue)
        default:
            return false
        }
    }
}

// MARK: - Conformances

extension Symbol.DataType: CustomStringConvertible {
    var description: String {
        switch self {
        case .array(let type):    return "[\(type)]"
        case .bool:               return "Bool"
        case .comment:            return "<Comment>"
        case .direction:          return "Direction"
        case .int:                return "Int"
        case .int8:               return "Int8"
        case .int16:              return "Int16"
        case .int32:              return "Int32"
        case .object:             return "Object"
        case .optional(let type): return "\(type)?"
        case .property(let type): return "<Property<\(type)>>"
        case .routine:            return "Routine"
        case .string:             return "String"
        case .table:              return "Table"
        case .thing:              return "Thing"
        case .unknown:            return "<Unknown>"
        case .variable(let type): return "\(type)"
        case .void:               return "Void"
        case .zilElement:         return "ZilElement"
        }
    }
}

extension Array where Element == Symbol.DataType {
    /// Returns the common type among the types in the array.
    var common: Symbol.DataType? {
        let uniqueTypes = unique

        if uniqueTypes.count == 1 {
            return uniqueTypes[0]
        }

        let literalTypes = uniqueTypes.filter { $0.isLiteral }
        if literalTypes.count == 1 {
            return literalTypes[0]
        }

        let knownTypes = uniqueTypes.filter { !$0.isUnknown }
        if knownTypes.count == 1 {
            return knownTypes[0]
        }

        let unambiguousTypes = uniqueTypes.filter { !$0.isUnambiguous }
        if unambiguousTypes.count == 1 {
            return unambiguousTypes[0]
        }

        return nil
    }
}
