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
    class DeclareType: Factory {
        override class var zilNames: [String] {
            ["#DECL"]
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

                    let variable = Variable(
                        id: zil.lowerCamelCase,
                        type: dataType,
                        confidence: .certain,
                        category: isGlobal ? .globals : nil
                    )

                    symbols.append(.variable(variable))

                    try localVariables.commit(variable)

                    if isGlobal {
                        try Game.commit(.variable(variable))
                    }
                }
            }
        }

        override func process() throws -> Symbol {
            let declareType = isGlobal ? "GlobalType" : "DeclareType"
            let comment = symbols
                .compactMap {
                    guard
                        let id = $0.id,
                        let type = $0.type,
                        type != .unknown
                    else { return nil }

                    return "// \(declareType) \(id): \(type)"
                }
                .joined(separator: "\n")

            return .statement(
                code: { _ in
                    comment
                },
                type: .comment,
                confidence: .certain
            )
        }
    }
}

extension Factories.DeclareType {
    func dataType(for typeToken: Token) -> DataType? {
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
