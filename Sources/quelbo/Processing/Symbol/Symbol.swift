//
//  Symbol.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import Foundation

enum Symbol: SymbolType {
    case definition(Definition)
    case literal(Literal)
    case statement(Statement)
    case instance(Instance)
    case variable(Variable)
}

extension Symbol {
    enum Returnable {
        case always
        case explicit
        case implicit
        case void
    }
}

extension Symbol {
    var canBeNilPlaceholder: Bool {
        self == .literal(false) || self == .literal(0)
    }

//    var canBeReturnValue: Bool {
//        guard !isReturn else { return false }
//
//        switch self {
//        case .definition:
//            return false
//        case .literal, .instance, .variable:
//            return true
//        case .statement(let statement):
//            return statement.returnable != .void &&
//                   statement.type?.hasReturnValue ?? false
//        }
//    }

    var category: Category? {
        switch self {
        case .definition(let definition): return definition.category
        case .literal(let literal): return literal.category
        case .statement(let statement): return statement.category
        case .instance(let instance): return instance.category
        case .variable(let variable): return variable.category
        }
    }

    var code: String {
        switch self {
        case .definition(let definition): return definition.code
        case .instance(let instance): return instance.code
        case .literal(let literal): return literal.code
        case .statement(let statement): return statement.code
        case .variable(let variable): return variable.code
        }
    }

    var confidence: DataType.Confidence? {
        switch self {
        case .definition(let definition): return definition.confidence
        case .instance(let instance): return instance.confidence
        case .literal(let literal): return literal.confidence
        case .statement(let statement): return statement.confidence
        case .variable(let variable): return variable.confidence
        }
    }

    var id: String? {
        switch self {
        case .definition(let definition): return definition.id
        case .instance, .literal: return nil
        case .statement(let statement): return statement.id
        case .variable(let variable): return variable.id
        }
    }

    var isMutable: Bool? {
        switch self {
        case .definition(let definition): return definition.isMutable
        case .instance(let instance): return instance.isMutable
        case .literal(let literal): return literal.isMutable
        case .statement(let statement): return statement.isMutable
        case .variable(let variable): return variable.isMutable
        }
    }

    var isRepeating: Bool {
        switch self {
        case .definition, .literal, .instance, .variable: return false
        case .statement(let statement): return statement.isRepeating
        }
    }

    var isReturn: Bool {
        switch self {
        case .definition, .literal, .instance, .variable: return false
        case .statement(let statement): return statement.quirk == .returnStatement
        }
    }

    var returnable: Returnable {
        switch self {
        case .definition: return .void
        case .literal, .instance, .variable: return .always
        case .statement(let statement): return statement.returnable
        }
    }

    var type: DataType? {
        switch self {
        case .definition(let definition): return definition.type
        case .instance(let instance): return instance.type
        case .literal(let literal): return literal.type
        case .statement(let statement): return statement.type
        case .variable(let variable): return variable.type
        }
    }
}
