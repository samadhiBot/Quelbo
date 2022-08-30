//
//  Restore.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [RESTORE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.40p60yl)
    /// function.
    class Restore: Factory {
        override class var zilNames: [String] {
            ["RESTORE"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(0))
            )
        }

        override func process() throws -> Symbol {
            .statement(
                code: { _ in
                    "restore()"
                },
                type: .void,
                confidence: .certain
            )
        }
    }
}
