//
//  Symbol.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import CustomDump
import Foundation

/// Represents the different types of symbols in the game.
enum Symbol: SymbolType {
    case definition(Definition)
    case literal(Literal)
    case statement(Statement)
    case instance(Instance)
}

extension Symbol {
    /// Returns the category of the symbol.
    var category: Category? {
        switch self {
        case .definition(let definition):
            return definition.category
        case .literal(let literal):
            return literal.category
        case .statement(let statement):
            return statement.category
        case .instance(let instance):
            return instance.category
        }
    }

    /// Returns the code representation of the symbol.
    var code: String {
        switch self {
        case .definition(let definition):
            return definition.code
        case .instance(let instance):
            return instance.code
        case .literal(let literal):
            return literal.code
        case .statement(let statement):
            return statement.code
        }
    }

    /// Returns the multi-type code representation of the symbol.
    ///
    /// Multi-type code representation is used in heterogeneous collections like tables.
    var codeMultiType: String {
        switch self {
        case .definition, .statement:
            return code
        case .instance, .literal:
            switch (type.dataType, category) {
            case (.bool, _):
                return code
            case (.int16, _):
                return ".int16(\(code))"
            case (.int32, _):
                return ".int32(\(code))"
            case (.int8, _):
                return ".int8(\(code))"
            case (.int, _):
                return code
            case (.object, .rooms):
                return code
            case (.object, .constants), (.object, .globals):
                return ".object(\(code))"
            case (.object, _):
                return isInstance ? ".object(\"\(code)\")" : ".object(\(code))"
            case (.string, _):
                return code
            case (.table, _):
                return isInstance ? ".table(\(code))" : handle
            default:
                return code
            }
        }
    }

    /// Returns the symbol's definition if it's a definition; otherwise, returns nil.
    var definition: Definition? {
        guard case .definition(let definition) = self else {
            return nil
        }
        return definition
    }

    /// Returns the evaluation of the symbol if it has one; otherwise, returns nil.
    var evaluation: Literal? {
        switch self {
        case .definition:
            return nil
        case .literal(let literal):
            return literal
        case .statement(let statement):
            return statement.payload.evaluation
        case .instance(let instance):
            return instance.variable.payload.evaluation
        }
    }

    /// Returns the global ID of the symbol if it's an instance; otherwise, returns the handle.
    var globalID: String {
        guard case .instance(let instance) = self else {
            return handle
        }
        return instance.globalID
    }

    /// Returns the handle representation of the symbol.
    var handle: String {
        switch self {
        case .definition(let definition):
            return definition.code
        case .instance(let instance):
            return instance.globalID
        case .literal(let literal):
            return literal.code
        case .statement(let statement):
            if statement.isFunctionCall || statement.category == .flags {
                return statement.code
            }
            return statement.id ?? statement.code
        }
    }

    /// Returns the multi-type handle representation of the symbol.
    var handleMultiType: String {
        if case .definition = self { return handle }

        var codeValue: String {
            isInstance ? globalID : code
        }

        switch (type.dataType, category, isInstance) {
        case (.bool, _, true):
            return ".int(\(globalID))"
        case (.bool, _, false):
            return code
        case (.int16, _, _):
            return ".int16(\(codeValue))"
        case (.int32, _, _):
            return ".int32(\(codeValue))"
        case (.int8, _, _):
            return ".int8(\(codeValue))"
        case (.int, _, true):
            return ".int(\(globalID))"
        case (.int, _, false):
            return code
        case (.object, .rooms, true):
            return ".room(\"\(code)\")"
        case (.object, .rooms, false):
            return ".room(\(code))"
        case (.object, .constants, _), (.object, .globals, _):
            return ".object(\(codeValue))"
        case (.object, _, true):
            return ".object(\"\(code)\")"
        case (.object, _, false):
            return ".object(\(code))"
        case (.string, _, true):
            return ".string(\(globalID))"
        case (.string, _, false):
            return code
        case (.table, _, true):
            return ".table(\(globalID))"
        case (.table, _, false):
            return handle
        default:
            return codeValue
        }
    }

    /// Returns the symbol's ID if it has one; otherwise, returns nil.
    var id: String? {
        switch self {
        case .definition(let definition):
            return definition.id
        case .instance(let instance):
            return instance.id
        case .literal(let literal):
            return literal.id
        case .statement(let statement):
            return statement.id
        }
    }

    /// Returns true if the symbol is a definition, otherwise, returns false.
    var isDefinition: Bool {
        if case .definition = self { return true }
        return false
    }

    /// Returns true if the symbol is an instance, otherwise, returns false.
    var isInstance: Bool {
        if case .instance = self { return true }
        return false
    }

    /// Returns true if the symbol is a literal, otherwise, returns false.
    var isLiteral: Bool {
        if case .literal = self { return true }
        return false
    }

    /// Returns the mutability of the symbol if it has one; otherwise, returns nil.
    var isMutable: Bool? {
        switch self {
        case .definition(let definition):
            return definition.isMutable
        case .instance(let instance):
            return instance.isMutable
        case .literal(let literal):
            return literal.isMutable
        case .statement(let statement):
            return statement.isMutable
        }
    }

    /// Returns true if the symbol is a property, otherwise, returns false.
    var isProperty: Bool {
        switch self {
        case .definition, .literal:
            return false
        case .instance(let instance):
            return instance.variable.type.isProperty == true
        case .statement(let statement):
            return statement.type.isProperty == true
        }
    }

    /// Returns true if the symbol is a repeating statement, otherwise, returns false.
    var isRepeating: Bool {
        guard case .statement(let statement) = self else {
            return false
        }
        return statement.isRepeating
    }

    /// Returns true if the symbol is a statement, otherwise, returns false.
    var isStatement: Bool {
        if case .statement = self { return true }
        return false
    }

    /// Returns true if the symbol is a throwing statement, otherwise, returns false.
    var isThrowing: Bool {
        guard case .statement(let statement) = self else {
            return false
        }
        return statement.isThrowing
    }

    /// Returns the object identifier (objID) of the symbol.
    var objID: String {
        let objID = {
            switch self {
            case .definition(let definition):
                return ObjectIdentifier(definition)
            case .instance(let instance):
                return ObjectIdentifier(instance)
            case .literal(let literal):
                return ObjectIdentifier(literal)
            case .statement(let statement):
                return ObjectIdentifier(statement)
            }
        }()
        return String("\(objID)".dropLast().suffix(4))
    }

    /// Returns the payload of the symbol if it's a statement; otherwise, returns nil.
    var payload: Statement.Payload? {
        guard case .statement(let statement) = self else {
            return nil
        }
        return statement.payload
    }

    /// Returns the return handling strategy of the symbol.
    var returnHandling: ReturnHandling {
        switch self {
        case .definition(let definition):
            return definition.returnHandling
        case .literal(let literal):
            return literal.returnHandling
        case .statement(let statement):
            return statement.returnHandling
        case .instance(let instance):
            return instance.returnHandling
        }
    }

    var signature: String {
        switch self {
        case .definition, .literal:
            return handle
        case .statement(let statement):
            return statement.signature
        case .instance(let instance):
            return instance.variable.signature
        }
    }

    /// Returns the try-handle representation of the symbol.
    var tryHandle: String {
        let code = handle
        if code.hasPrefix("try ") {
            return code
        }
        return "try \(code)"
    }

    /// Returns the type information of the symbol.
    var type: TypeInfo {
        switch self {
        case .definition(let definition):
            return definition.type
        case .instance(let instance):
            return instance.type
        case .literal(let literal):
            return literal.type
        case .statement(let statement):
            return statement.type
        }
    }
}

extension Symbol: CustomDebugStringConvertible {
    var debugDescription: String {
        var description = ""
        switch self {
        case .definition(let definition): customDump(definition, to: &description)
        case .literal(let literal): customDump(literal, to: &description)
        case .statement(let statement): customDump(statement, to: &description)
        case .instance(let instance): customDump(instance, to: &description)
        }
        return description
    }
}
