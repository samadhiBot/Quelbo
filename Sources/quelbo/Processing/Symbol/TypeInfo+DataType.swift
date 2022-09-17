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
        indirect case oneOf(Set<DataType>)
        indirect case property(DataType)
    }
}

// MARK: - Helper methods

extension TypeInfo.DataType  {
    /// <#Description#>
    var baseConfidence: TypeInfo.Confidence {
        switch self {
        case .bool: return .booleanFalse
        case .int, .int16, .int32, .int8: return .integerZero
        case .unknown: return .unknown
        case .void: return .void
        default: return .certain
        }
    }

    /// Whether the symbol with this data type can take a `.zilElement` value.
    var canBeZilElement: Bool {
        switch self {
        case .bool, .int, .int16, .int32, .int8, .object, .string, .table, .zilElement:
            return true
        case .comment, .direction, .function, .routine, .thing, .unknown, .void:
            return false
        case .array(let dataType):
            return dataType.canBeZilElement
        case .oneOf(let set):
            return set.contains { $0.canBeZilElement }
        case .property(let dataType):
            return dataType.canBeZilElement
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
}

// MARK: - Conformances

extension Set where Element == TypeInfo.DataType {
    /// <#Description#>
    /// - Returns: <#description#>
    var preferred: TypeInfo.DataType {
        if let found = first(where: {
            if case .table = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .bool = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .comment = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .direction = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .int = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .int16 = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .int32 = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .int8 = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .object = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .routine = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .string = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .thing = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .unknown = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .void = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .zilElement = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .array = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .function = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .oneOf = $0 { return true } else { return false }
        }) { return found }
        if let found = first(where: {
            if case .property = $0 { return true } else { return false }
        }) { return found }

        return .zilElement
    }
}

extension TypeInfo.DataType: CustomDebugStringConvertible {
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
            return "(\(params.map(\.debugDescription).values(.commaSeparated))) -> \(type)"
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
            return "<\(types.map(\.debugDescription).joined(separator: " | "))>"
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

extension TypeInfo.DataType: CustomStringConvertible {
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
        case .oneOf(let types):
            return types.preferred.description
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
