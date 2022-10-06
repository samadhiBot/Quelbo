//
//  Parse.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PARSE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2eclud0)
    /// functions.
    class Parse: Factory {
        override class var zilNames: [String] {
            ["PARSE"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.atLeast(1)))
        }

        override func process() throws -> Symbol {
            let elements = symbols

            return .statement(
                code: { _ in
                    "[\(elements.codeValues(.commaSeparated))].parse()"
                },
                type: .verb
            )
        }
    }
}
