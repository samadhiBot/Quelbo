//
//  Return.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/23/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [RETURN](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2fugb6e)
    /// function.
    class Return: Factory {
        override class var zilNames: [String] {
            ["RETURN", "RETURN!-"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.atLeast(0)))
        }

        override func process() throws -> Symbol {
            if let valueSymbol = symbols.shift() {
                return valueReturn(valueSymbol)
            } else if Game.shared.zMachineVersion > .z4 {
                return z5Return()
            } else {
                return breakReturn()
            }
        }
    }
}

extension Factories.Return {
    func breakReturn() -> Symbol {
        .statement(
            code: { statement in
                guard let activation = statement.activation else { return "break" }

                return "break \(activation)"
            },
            type: .void
        )
    }

    func valueReturn(_ value: Symbol) -> Symbol{
        .statement(
            code: { _ in
                "return \(value.code)"
            },
            type: value.type,
            isReturnStatement: true
        )
    }

    func z5Return() -> Symbol{
        .statement(
            code: { _ in
                "return true"
            },
            type: .bool,
            isReturnStatement: true
        )
    }
}
