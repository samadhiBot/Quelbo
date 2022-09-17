//
//  StackPush.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PUSH](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.pv6qcq)
    /// function.
    class StackPush: Factory {
        override class var zilNames: [String] {
            ["PUSH"]
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
                    "Stack.push(\(value.code))"
                },
                type: .void
            )
        }
    }
}
