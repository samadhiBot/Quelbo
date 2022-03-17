//
//  Variable+Parameter.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/10/22.
//

import Foundation

extension Variable {
    struct Parameter: Equatable {
        private(set) var name: String = ""
        private(set) var type: String = ""
        private(set) var defaultValue: String = ""
        let context: Context
    }
}

extension Variable.Parameter{
    enum Err: Error {
        case missingNameInList(String)
        case missingTypeInList(String)
        case unimplemented(String)
    }

    enum Context {
        case normal
        case auxiliary
        case optional
    }

    init(_ token: Token, _ context: Context) throws {
        self.context = context

        switch token {
        case .atom(let string): processAtom(string)
        // .bool parsing catches params called "T"
        case .bool:             processAtom("T")
        case .list(let tokens): try processList(tokens)
        default: throw Err.unimplemented("\(token)") 
        }
    }

    var definition: String {
        switch context {
        case .normal:
            return "\(name): \(type)\(defaultValue)"
        case .auxiliary:
            return "var \(name): \(type)\(defaultValue)"
        case .optional:
            return "\(name): \(type)\(defaultValue)"
        }

    }
}

private extension Variable.Parameter{
    mutating func processAtom(_ name: String) {
        let variable = Variable(name)
        self.name = variable.name
        self.type = variable.typeOrUnknown

        if context == .optional {
            switch type {
            case "Bool":
                self.defaultValue = " = false"
            default:
                self.defaultValue = "? = nil"
            }
        }
    }

    mutating func processList(_ listTokens: [Token]) throws {
        var tokens = listTokens
        guard let nameToken = tokens.shiftAtom() else {
            throw Err.missingNameInList("\(listTokens)")
        }
        self.name = try nameToken.process()
        guard let typeToken = tokens.shift() else {
            throw Err.missingTypeInList("\(listTokens)")
        }
        switch typeToken {
        case .atom(_):
            break
        case .bool(let value):
            self.type = "Bool"
            self.defaultValue = " = \(value)"
        case .commented(_):
            break
        case .decimal(let value):
            self.type = "Int"
            self.defaultValue = " = \(value)"
        case .form(let tokens):
            self.type = "Unknown"
            self.defaultValue = " = \(tokens)"
        case .list(_):
            break
        case .quoted(_):
            break
        case .string(let value):
            self.type = "String"
            self.defaultValue = " = \(value)"
        }
    }
}
