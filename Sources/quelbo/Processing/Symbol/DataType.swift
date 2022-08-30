//
//  DataType.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import Foundation

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
    indirect case function([DataType], DataType)
    indirect case optional(DataType)
    indirect case property(DataType)
}

// MARK: - Helper methods

extension DataType {
    var asOptional: DataType {
        if case .optional = self { return self }

        return .optional(self)
    }

    var baseConfidence: Confidence {
        switch self {
        case .bool: return .booleanFalse
        case .int, .int16, .int32, .int8: return .integerZero
        case .unknown: return .unknown
        case .void: return .void
        default: return .certain
        }
    }

//    /// <#Description#>
//    var baseType: Self {
//        switch self {
//        case .property(let type): return type.baseType
//        default: return self
//        }
//    }
//
//    /// Whether the symbol with this data type can take a literal value.
//    var canBeLiteral: Bool {
//        switch self {
//        case .object, .property, .table: return false
//        default: return true
//        }
//    }
//
//    /// Whether the symbol with this data type can take a `.zilElement` value.
//    var canBeZilElement: Bool {
//        switch self {
//        case .direction, .property, .routine, .thing, .unknown, .void:
//            return false
//        default:
//            return true
//        }
//    }

    /// An empty placeholder value for the data type.
    var emptyValueAssignment: String {
        switch self {
        case .bool: return " = false"
        case .comment, .unknown, .void: return " = \(self)"
        case .direction, .function, .object, .routine, .table, .thing: return "? = nil"
        case .int, .int8, .int16, .int32: return " = 0"
        case .optional, .property: return " = nil"
        case .string: return " = \"\""
        case .array: return " = []"
        case .zilElement: return " = .none"
        }
    }

    /// Whether the data type has a return value.
    var hasReturnValue: Bool {
        switch self {
        case .array(let type): return type.hasReturnValue
        case .comment, .unknown, .void: return false
        case .property(let type): return type.hasReturnValue
        default: return true
        }
    }

//    /// Whether the data type is a literal value type.
//    var isLiteral: Bool {
//        switch self {
//        case .array(let type): return type.isLiteral
//        case .bool, .direction, .int, .int8, .int16, .int32, .string: return true
//        default: return false
//        }
//    }
//
//    /// Whether the data type is a property value type.
//    var isProperty: Bool {
//        if case .property = self { return true } else { return false }
//    }
//
//    /// Whether the data type is unambiguous, i.e. is known and homogeneous.
//    var isUnambiguous: Bool {
//        switch self {
//        case .array(let type): return type.isUnambiguous
//        case .property(let type): return type.isUnambiguous
//        case .unknown, .zilElement: return false
//        default: return true
//        }
//    }
//
//    /// Whether the data type is ``DataType-swift.enum/unknown``.
//    var isUnknown: Bool {
//        switch self {
//        case .array(let type): return type.isUnknown
//        case .property(let type): return type.isUnknown
//        case .unknown: return true
//        default: return false
//        }
//    }
}

// MARK: - Conformances

extension DataType: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .array(let type):
            return "<Array<\(type)>>"
        case .bool:
            return "Bool"
        case .comment:
            return "<Comment>"
        case .direction:
            return "Direction"
        case .function(let params, let type):
            return "(\(params.map(\.description).values(.commaSeparated))) -> \(type)"
        case .int:
            return "Int"
        case .int8:
            return "Int8"
        case .int16:
            return "Int16"
        case .int32:
            return "Int32"
        case .object:
            return "Object"
        case .optional(let type):
            return "\(type)?"
        case .property(let type):
            return "<Property<\(type)>>"
        case .routine:
            return "Routine"
        case .string:
            return "String"
        case .table:
            return "Table"
        case .thing:
            return "Thing"
        case .unknown:
            return "<Unknown>"
        case .void:
            return "Void"
        case .zilElement:
            return "ZilElement"
        }
    }
}

extension DataType: CustomStringConvertible {
    var description: String {
        switch self {
        case .array(let type):
            return "[\(type)]"
        case .bool:
            return "Bool"
        case .comment:
            return "<Comment>"
        case .direction:
            return "Direction"
        case .function(let params, let type):
            return "(\(params.map(\.description).values(.commaSeparated))) -> \(type)"
        case .int:
            return "Int"
        case .int8:
            return "Int8"
        case .int16:
            return "Int16"
        case .int32:
            return "Int32"
        case .object:
            return "Object"
        case .optional(let type):
            return "\(type)?"
        case .property(let type):
            return "<Property<\(type)>>"
        case .routine:
            return "Routine"
        case .string:
            return "String"
        case .table:
            return "Table"
        case .thing:
            return "Thing"
        case .unknown:
            return "<Unknown>"
        case .void:
            return "Void"
        case .zilElement:
            return "ZilElement"
        }
    }
}
