//
//  PrimitiveType.swift
//  Quelbo
//
//  Created by Chris Sessions on 9/10/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PRIMTYPE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4cmhg48)
    /// function.
    class PrimitiveType: Factory {
        override class var zilNames: [String] {
            ["PRIMTYPE"]
        }

        override func processTokens() throws {
            if tokens.count == 1, let typeStatement = typeStatement(for: tokens[0]) {
                self.symbols = [.statement(typeStatement)]
            } else {
                self.symbols = try symbolize(tokens)
            }
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1))
            )
        }

        override func process() throws -> Symbol {
            let value = symbols[0]

            return .statement(
                code: { _ in
                    value.code
                },
                type: value.type
            )
        }
    }
}

extension Factories.PrimitiveType {
    func typeStatement(for typeToken: Token) -> Statement? {
        switch typeToken {
        case .atom("FALSE"):
            return .init(
                code: { _ in "Bool" },
                type: .bool
            )
        case .atom("FIX"), .character:
            return .init(
                code: { _ in "Int" },
                type: .int
            )
        case .atom("OBJECT"):
            return .init(
                code: { _ in "Object" },
                type: .object
            )
        case .atom("TABLE"):
            return .init(
                code: { _ in "Table" },
                type: .table
            )
        case .atom("VECTOR"):
            return .init(
                code: { _ in "Array" },
                type: .unknown.array
            )
        case .string:
            return .init(
                code: { _ in "String" },
                type: .string
            )
        default:
            return nil
        }
    }
}
