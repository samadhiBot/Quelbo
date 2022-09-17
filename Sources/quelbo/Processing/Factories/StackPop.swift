//
//  StackPop.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/24/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PUSH](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.pv6qcq)
    /// function.
    class StackPop: Factory {
        override class var zilNames: [String] {
            ["RSTACK"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(0))
            )
        }

        override func process() throws -> Symbol {
            .statement(
                code: { _ in
                    "Stack.pop()"
                },
                type: .zilElement
            )
        }
    }
}
