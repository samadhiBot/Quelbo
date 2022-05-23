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
        case zilElement
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
            case .list, .object, .property, .unknown: return false
            default: return true
            }
        }

        /// Whether the data type is a literal value type.
        var isLiteral: Bool {
            switch self {
            case .array(let dataType): return dataType.isLiteral
            case .bool, .direction, .int, .string, .zilElement: return true
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
        case .zilElement:      return "ZilElement"
        case .unknown:         return "<Unknown>"
        case .void:            return "Void"
        }
    }
}
