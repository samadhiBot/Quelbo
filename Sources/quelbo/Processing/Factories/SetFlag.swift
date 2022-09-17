//
//  SetFlag.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [FSET](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4ihyjke)
    /// function.
    class SetFlag: Factory {
        override class var zilNames: [String] {
            ["FSET"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(2)))

            try symbols[0].assert(.hasType(.object))
            try symbols[1].assert(.hasType(.bool))
        }

        var value: Bool { true }

        override func process() throws -> Symbol {
            let object = symbols[0]
            let flag = symbols[1]
            let value = value

            return .statement(
                code: { _ in
                    "\(object.code).\(flag.code).set(\(value))"
                },
                type: .bool
            )
        }
    }
}
