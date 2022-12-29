//
//  InsertFile.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/20/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GLOBAL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2szc72q)
    /// function.
    ///
    /// Returns an empty statement, since Quelbo ignores `INSERT-FILE` directives, and instead
    /// iterates over the entire Zil codebase repeatedly until the translation is complete.
    class InsertFile: Factory {
        override class var zilNames: [String] {
            ["INSERT-FILE"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2)),
                .haveType(.string)
            )
        }

        override func process() throws -> Symbol {
            .emptyStatement
        }
    }
}
