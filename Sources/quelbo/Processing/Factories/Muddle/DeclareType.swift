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

        var idValue: String {
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
                    throw FactoryError.missingParameters(tokens)
                }
                let dataType = try dataType(for: typeToken)

                try nameTokens.forEach { nameToken in
                    guard case .atom(let zil) = nameToken else {
                        throw FactoryError.invalidProperty(nameToken)
                    }
                    let name = zil.lowerCamelCase
                    let symbol = Symbol(
                        id: name,
                        code: "var \(name): \(dataType)",
                        type: dataType,
                        category: isGlobal ? .globals : nil
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
    func dataType(for typeToken: Token) throws -> Symbol.DataType {
        switch typeToken {
        case .atom("FALSE"):
            return .bool
        case .atom("FIX"):
            return .int
        case .form(let tokens):
            for token in tokens {
                if let dataType = try? dataType(for: token) {
                    return dataType
                }
            }
        default:
            break
        }
        throw FactoryError.invalidProperty(typeToken)
    }
}
