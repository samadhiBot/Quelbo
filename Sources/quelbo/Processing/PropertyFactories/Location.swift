//
//  Location.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `IN` / `LOC` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Location: PropertyFactory {
        override class var zilNames: [String] {
            ["IN", "LOC"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.between(0...1)),
                .haveType(.object),
            ])
        }
        
        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "location" },
                    type: .object,
                    confidence: .certain
                )
            }
            let room = symbols[0]

            return .statement(
                id: "location",
                code: { _ in
                    "location: \(room.code)"
                },
                type: .object,
                confidence: .certain,
                category: .rooms
            )
        }
    }
}
