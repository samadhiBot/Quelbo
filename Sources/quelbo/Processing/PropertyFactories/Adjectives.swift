//
//  Adjectives.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `ADJECTIVE` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Adjectives: PropertyFactory {
        override class var zilNames: [String] {
            ["ADJECTIVE"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveTypeIn([.string, .direction]),
            ])
        }

        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "adjectives" },
                    type: .array(.string),
                    confidence: .certain
                )
            }

            let adjectives = symbols.map(\.code.quoted)

            return .statement(
                id: "adjectives",
                code: { _ in
                    "adjectives: [\(adjectives.values(.commaSeparated))]"
                },
                type: .array(.string),
                confidence: .certain
            )
        }
    }
}
