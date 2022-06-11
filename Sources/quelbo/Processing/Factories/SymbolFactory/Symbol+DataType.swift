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
        case object
        case property
        case routine
        case string
        case table
        case thing
        case unknown
        case void
        case zilElement
        indirect case array(DataType)
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

    /// An empty, placeholder value for the data type.
    var emptyValue: String {
        switch self {
        case .bool: return "false"
        case .comment: break
        case .direction: break
        case .int: return "0"
        case .object: return ".nullObject"
        case .property: break
        case .routine: break
        case .string: return #""""#
        case .table: break
        case .thing: break
        case .unknown: break
        case .void: break
        case .zilElement: return #".string("")"#
        case .array: return "[]"
        case .variable: break
        }
        return "???"
    }

    /// Whether the data type has a known return value type.
    var hasKnownReturnValue: Bool {
        switch self {
        case .array(let type): return type.hasKnownReturnValue
        case .comment, .property, .unknown: return false
        case .variable(let type): return type.hasKnownReturnValue
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
        case .comment, .object: return true // FIXME: is a comment really a container?
        default: return false
        }
    }

    /// Whether the data type is a literal value type.
    var isLiteral: Bool {
        switch self {
        case .array(let type): return type.isLiteral
        case .bool, .direction, .int, .string, .zilElement: return true
        default: return false
        }
    }

    /// Whether the data type is unambiguous, i.e. is known and homogeneous.
    var isUnambiguous: Bool {
        switch self {
        case .array(let type): return type.isUnambiguous
        case .unknown, .zilElement: return false
        case .variable(let type): return type.isUnambiguous
        default: return true
        }
    }

    /// Whether the data type is ``Symbol/DataType-swift.enum/unknown``.
    var isUnknown: Bool {
        switch self {
        case .array(let type): return type.isUnknown
        case .unknown: return true
        case .variable(let type): return type.isUnknown
        default: return false
        }
    }

    /// Whether the data type should supersede the one in the specified symbol in the case of a
    /// type conflict.
    ///
    /// - Parameter symbol: A symbol with a conflicting type.
    ///
    /// - Returns: Whether the data type should supersede the one in the specified symbol.
    func supersedes(_ id: Symbol.Identifier) -> Bool {
        guard
            self == .object,
            let committed = try? Game.find(id),
            committed.meta.contains(.maybeEmptyValue)
        else {
            return false
        }
        return true
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
        case .object:             return "Object"
        case .property:           return "<Property>"
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
