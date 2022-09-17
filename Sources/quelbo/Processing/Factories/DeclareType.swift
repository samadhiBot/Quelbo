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
    /// and
    /// [GDECL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.k62wjra3zbsy)
    /// type declarations.
    class DeclareType: Factory {
        override class var zilNames: [String] {
            ["#DECL", "GDECL"]
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
                
                try nameTokens.forEach { nameToken in
                    guard case .atom(let zil) = nameToken else {
                        throw Error.invalidDeclareTypeVariable(nameToken)
                    }

                    let dataType = try dataType(for: typeToken)

                    symbols.append(
                        .statement(
                            code: { _ in
                                "\(zil.lowerCamelCase): \(dataType)"
                            },
                            type: .comment
                        )
                    )
                }
            }
        }

        override func process() throws -> Symbol {
            let types = symbols

            return .statement(
                code: { _ in
                    "Declare(\(types.codeValues(.commaSeparatedNoTrailingComma)))".commented
                },
                type: .comment
            )
        }
    }
}

extension Factories.DeclareType {
    func dataType(for typeToken: Token) throws -> String {
        switch typeToken {
        case .atom("FALSE"):
            return "Bool"
        case .atom("FIX"):
            return "Int"
        case .atom("OBJECT"):
            return "Object"
        case .atom("TABLE"):
            return "Table"
        case .atom("VECTOR"):
            return "Array"
        default:
            let symbol = try symbolize(typeToken)
            return symbol.code
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
