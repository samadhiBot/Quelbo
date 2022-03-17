//
//  Token+Process.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/12/22.
//

import Foundation

extension Token {
    func process() throws -> String {
        switch self {
        case .atom(let string):     return try processAtom(string)
        case .bool(let bool):       return try processBool(bool)
        case .commented(let token): return try processCommented(token)
        case .decimal(let int):     return try processDecimal(int)
        case .form(let tokens):     return try processForm(tokens)
        case .list(let tokens):     return try processList(tokens)
        case .quoted(let token):    return try processQuoted(token)
        case .string(let string):   return try processString(string)
        }
    }
}

private extension Token {
    func processAtom(_ value: String) throws -> String {
        Variable(value).name
    }

    func processBool(_ value: Bool) throws -> String {
        "\(value)"
    }

    func processCommented(_ token: Token) throws -> String {
        "// \(try token.process())"
    }

    func processDecimal(_ value: Int) throws -> String {
        "\(value)"
    }

    func processForm(_ formTokens: [Token]) throws -> String {
        var tokens = formTokens
        guard case .atom(let command) = tokens.shiftAtom() else {
            fatalError("No command: \(formTokens)")
        }
        if let zil = Zil(command) {
            return try zil.process(tokens)
        } else {
            let arguments = try tokens
                .map { try $0.process() }
                .joined(separator: ", ")
            return "\(command.lowerCamelCase)(\(arguments))"
        }
    }

    func processList(_ tokens: [Token]) throws -> String {
        "(\(try tokens.map { try $0.process() }.joined(separator: ", "))"
    }

    func processQuoted(_ token: Token) throws -> String {
        try token.process().quoted()
    }

    func processString(_ value: String) throws -> String {
        value.quoted()
    }
}
