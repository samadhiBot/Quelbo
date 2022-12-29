//
//  TypeInfo+DataType.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import Foundation

extension TypeInfo {
    /// <#Description#>
    enum DataType: Hashable {
        case atom
        case bool
        case comment
//        case direction
        case int
        case int16
        case int32
        case int8
        case object
        case routine
        case string
        case table
        case tableElement
        case thing
        case verb
        case void
        case word
        indirect case oneOf(Set<DataType>)
    }
}

// MARK: - Helper methods

extension TypeInfo.DataType  {
    /// <#Description#>
    var baseConfidence: TypeInfo.Confidence {
        switch self {
        case .bool: return .booleanFalse
        case .int, .int16, .int32, .int8: return .integerZero
        case .tableElement: return .none
        case .void: return .void
        default: return .certain
        }
    }

    /// Whether the symbol with this data type can take a `.someTableElement` value.
    var canBeTableElement: Bool {
        switch self {
        case .atom, .comment, .routine, .thing, .void:
            return false
        case .oneOf(let set):
            return set.contains { $0.canBeTableElement }
        default:
            return true
        }
    }

    /// Whether the data type has a return value.
    var hasReturnValue: Bool {
        switch self {
        case .comment, .void: return false
        default: return true
        }
    }
}

// MARK: - Conformances

extension TypeInfo.DataType: CustomStringConvertible {
    var description: String {
        switch self {
        case .atom:
            return "<zilAtom>"
        case .bool:
            return "Bool"
        case .comment:
            return "<Comment>"
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
        case .oneOf(let types):
            return "<OneOf<\(types)>>"
        case .routine:
            return "Routine"
        case .string:
            return "String"
        case .table:
            return "Table"
        case .tableElement:
            return "TableElement"
        case .thing:
            return "Thing"
        case .verb:
            return "Verb"
        case .void:
            return "Void"
        case .word:
            return "Word"
        }
    }
}
