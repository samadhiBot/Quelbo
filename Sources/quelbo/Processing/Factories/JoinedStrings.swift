//
//  JoinedStrings.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [STRING](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1ulbmlt)
    /// function.
    class JoinedStrings: Factory {
        override class var zilNames: [String] {
            ["STRING"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(1)),
                .haveType(.string)
            )
        }

        override func process() throws -> Symbol {
            let elements = symbols

            return .statement(
                code: { _ in
                    "[\(elements.codeValues(.commaSeparated))].joined()"
                },
                type: .string
            )
        }
    }
}
