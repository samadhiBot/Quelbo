//
//  Global.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

/// `Global` declares a global variable, that can be used later inside a ``Routine``.
///
/// Refer to the [ZILF Reference Guide](https://bit.ly/3Kuu6GA) for details.
struct Global {
    private var tokens: [Token]
    private var isMutable: Bool

    init(
        _ tokens: [Token],
        isMutable: Bool = false
    ) {
        self.tokens = tokens
        self.isMutable = isMutable
    }
}

extension Global {
    enum Err: Error {
        case invalidValue(String)
        case missingName
        case missingValue
        case missingType
        case unconsumedTokens(String)
        case unknownType(String)
    }

    mutating func process() throws -> Muddle.Definition {
        guard let name = try tokens.shiftAtom()?.process() else {
            throw Err.missingName
        }
        guard let token = tokens.shift() else {
            throw Err.missingValue
        }
        guard tokens.isEmpty else {
            throw Err.unconsumedTokens("\(tokens)")
        }

        switch token {
        case .atom(let value):
            guard value == "T" else {
                throw Err.invalidValue("atom: \(token)")
            }
            return .init(
                name: name,
                code: "\(declare) \(name): Bool = true",
                dataType: .bool,
                defType: .global,
                isMutable: isMutable
            )
        case .bool(let value):
            return .init(
                name: name,
                code: "\(declare) \(name): Bool = \(value)",
                dataType: .bool,
                defType: .global,
                isMutable: isMutable
            )
        case .commented:
            throw Err.invalidValue("commented: \(token)")
        case .decimal(let value):
            return .init(
                name: name,
                code: "\(declare) \(name): Int = \(value)",
                dataType: .int,
                defType: .global,
                isMutable: isMutable
            )
        case .form(let values):
            return try processForm(name, values)
        case .list:
            throw Err.invalidValue("list: \(token)")
        case .quoted:
            throw Err.invalidValue("quoted: \(token)")
        case .string(let value):
            return .init(
                name: name,
                code: "\(declare) \(name): String = \(value.quoted())",
                dataType: .string,
                defType: .global,
                isMutable: isMutable
            )
        }
    }
}

private extension Global {
    var declare: String {
        isMutable ? "var" : "let"
    }

    func processForm(_ name: String, _ formTokens: [Token]) throws -> Muddle.Definition {
        var tokens = formTokens
        guard let type = try tokens.shiftAtom()?.process() else {
            throw Err.missingType
        }
        switch type {
        case "itable":
            return .init(
                name: name,
                code: "var \(name): String = \"\"",
                dataType: .string,
                defType: .global,
                isMutable: isMutable
            )
        case "ltable", "table":
            let table = try Table(tokens, isMutable: isMutable)
            return .init(
                name: name,
                code: "\(table.declare) \(name): [TableElement] = \(table.definition)",
                dataType: .table,
                defType: .global,
                isMutable: table.isMutable
            )
        default:
            throw Err.unknownType("\(type) \(tokens)")
        }
    }
}
