//
//  DeclareType.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the MDL
    /// [#DECL](https://mdl-language.readthedocs.io/en/latest/14-data-type-declarations/#143-the-decl-syntax)
    /// local type declaration.
    class DeclareType: MuddleFactory {
        override class var zilNames: [String] {
            ["#DECL"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .twoOrMore(.unknown)
        }

        var idValue: Symbol.Identifier {
            "<DeclareType>"
        }

        var isGlobal: Bool {
            false
        }

        override func processTokens() throws {
            var typeTokens = tokens
            while !typeTokens.isEmpty {
                guard
                    case .list(let nameTokens) = typeTokens.shift(),
                    let typeToken = typeTokens.shift()
                else {
                    throw Error.missingDeclareTypeVariable(tokens)
                }
                guard let dataType = dataType(for: typeToken) else {
                    continue
                }

                try nameTokens.forEach { nameToken in
                    guard case .atom(let zil) = nameToken else {
                        throw Error.invalidDeclareTypeVariable(nameToken)
                    }
                    let name = zil.lowerCamelCase
                    let symbol = Symbol(
                        id: .id(name),
                        code: "var \(name): \(dataType)\(dataType.emptyValueAssignment)",
                        type: dataType.emptyValueType,
                        category: isGlobal ? .globals : nil,
                        meta: dataType.emptyMeta
                    )
                    symbols.append(symbol)

                    if isGlobal {
                        try Game.commit(symbol)
                    }
                }
            }
        }

        override func process() throws -> Symbol {
            Symbol(
                id: idValue,
                children: symbols
            )
        }
    }
}

extension Factories.DeclareType {
    func dataType(for typeToken: Token) -> Symbol.DataType? {
        switch typeToken {
        case .atom("FALSE"):
            return .bool
        case .atom("FIX"):
            return .int
        case .atom("OBJECT"):
            return .object
        case .atom("TABLE"):
            return .table
        case .atom("VECTOR"):
            return .array(.zilElement)
        case .form(let tokens):
            let types = tokens.compactMap { dataType(for: $0) }
            return types.count == 1 ? types.first : nil
        default:
            return nil
        }
    }
}

// MARK: - Errors

extension Factories.DeclareType {
    enum Error: Swift.Error {
        case invalidDeclareTypeVariable(Token)
        case missingDeclareTypeVariable([Token])
    }
}
