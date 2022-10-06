//
//  Globals.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `GLOBAL` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Globals: Factory {
        override class var factoryType: FactoryType {
            .property
        }

        override class var zilNames: [String] {
            ["GLOBAL"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveType(.object)
            )
        }

        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "globals" },
                    type: .array(.object)
                )
            }

            let globals = symbols

            return .statement(
                id: "globals",
                code: { _ in
                    "globals: [\(globals.codeValues(.commaSeparated))]"
                },
                type: .array(.object)
            )
        }
    }
}
