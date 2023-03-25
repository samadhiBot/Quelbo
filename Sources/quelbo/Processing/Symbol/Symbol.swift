//
//  Symbol.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import CustomDump
import Foundation

enum Symbol: SymbolType {
    case definition(Definition)
    case literal(Literal)
    case statement(Statement)
    case instance(Instance)
}

extension Symbol {
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

    var definition: Definition? {
        guard case .definition(let definition) = self else {
            return nil
        }
        return definition
    }

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

    var globalID: String {
        guard case .instance(let instance) = self else {
            return handle
        }
        return instance.globalID
    }

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

    var handleMultiType: String {
        if case .definition = self { return handle }

        var codeValue: String {
            isInstance ? globalID : code
        }

        switch (type.dataType, category) {
        case (.bool, _):
            return codeValue
        case (.int16, _):
            return ".int16(\(codeValue))"
        case (.int32, _):
            return ".int32(\(codeValue))"
        case (.int8, _):
            return ".int8(\(codeValue))"
        case (.int, _):
            return codeValue
        case (.object, .rooms):
            return category == nil ? handle : ".room(\"\(code)\")"
        case (.object, .constants), (.object, .globals):
            return ".object(\(codeValue))"
        case (.object, _):
            return isInstance ? ".object(\"\(code)\")" : ".object(\(codeValue))"
        case (.string, _):
            return codeValue
        case (.table, _):
            return isInstance ? ".table(\(codeValue))" : handle
        default:
            return codeValue
        }
    }

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

    var isDefinition: Bool {
        if case .definition = self { return true }
        return false
    }

    var isInstance: Bool {
        if case .instance = self { return true }
        return false
    }

    var isLiteral: Bool {
        if case .literal = self { return true }
        return false
    }

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

    var isRepeating: Bool {
        guard case .statement(let statement) = self else {
            return false
        }
        return statement.isRepeating
    }

    var isStatement: Bool {
        if case .statement = self { return true }
        return false
    }

    var isThrowing: Bool {
        guard case .statement(let statement) = self else {
            return false
        }
        return statement.isThrowing
    }

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

    var payload: Statement.Payload? {
        guard case .statement(let statement) = self else {
            return nil
        }
        return statement.payload
    }

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

    var tryHandle: String {
        let code = handle
        if code.hasPrefix("try ") {
            return code
        }
        return "try \(code)"
    }

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
