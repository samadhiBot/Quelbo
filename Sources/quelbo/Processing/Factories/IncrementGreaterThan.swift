//
//  IncrementGreaterThan.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [IGRTR?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.23muvy2)
    /// function.
    class IncrementGreaterThan: Factory {
        override class var zilNames: [String] {
            ["IGRTR?"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.exactly(2)),
                .haveType(.int)
            ])

            try symbols[0].assert(.isVariable)
        }

        override func process() throws -> Symbol {
            let variable = symbols[0]
            let value = symbols[1]

            return .statement(
                code: { _ in
                    "\(variable.code).increment().isGreaterThan(\(value.code))"
                },
                type: .bool,
                confidence: .certain
            )
        }
    }
}
