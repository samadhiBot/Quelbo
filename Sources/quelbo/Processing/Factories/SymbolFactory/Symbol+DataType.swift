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
        case thing
        case unknown
        case void
        case zilElement
        indirect case array(DataType)
        indirect case variable(DataType)

        /// Whether the data type can be a literal value.
        var acceptsLiteral: Bool {
            switch self {
            case .object, .property, .variable: return false
            default: return true
            }
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
            case .comment, .object: return true
            default: return false
            }
        }

        /// Whether the data type is known.
        var isKnown: Bool {
            switch self {
            case .array(let type): return type.isKnown
            case .object, .property, .unknown: return false
            case .variable(let type): return type.isKnown
            default: return true
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
    }
}

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
        case .thing:              return "Thing"
        case .unknown:            return "<Unknown>"
        case .variable(let type): return "\(type)"
        case .void:               return "Void"
        case .zilElement:         return "ZilElement"
        }
    }
}
