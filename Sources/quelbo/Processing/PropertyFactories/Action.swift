//
//  Action.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `ACTION` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Action: Factory {
        override class var factoryType: FactoryType {
            .property
        }

        override class var zilNames: [String] {
            ["ACTION"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.between(0...1)),
                .haveType(.routine.property)
            )
        }

        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "action" },
                    type: .routine
                )
            }

            let action = symbols[0]

            return .statement(
                id: "action",
                code: { _ in
                    "action: \(action.handle.quoted)"
                },
                type: .routine
            )
        }
    }
}
