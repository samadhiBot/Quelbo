//
//  Save.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [SAVE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2t9m75f)
    /// function.
    class Save: Factory {
        override class var zilNames: [String] {
            ["SAVE"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(0))
            )
        }

        override func process() throws -> Symbol {
            .statement(
                code: { _ in
                    "save()"
                },
                type: .void,
                confidence: .certain
            )
        }
    }
}
