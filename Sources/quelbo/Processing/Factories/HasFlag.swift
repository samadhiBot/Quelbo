//
//  HasFlag.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [FSET?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2xn8ts7)
    /// function.
    class HasFlag: Factory {
        override class var zilNames: [String] {
            ["FSET?"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(2)))

            try symbols[0].assert(.hasType(.object))

            try symbols[1].assert(.hasType(.bool))
        }

        override func process() throws -> Symbol {
            let object = symbols[0]
            let flag = symbols[1]

            return .statement(
                code: { _ in
                    "\(object.code).hasFlag(\(flag.code))"
                },
                type: .bool,
                confidence: .certain
            )
        }
    }
}
