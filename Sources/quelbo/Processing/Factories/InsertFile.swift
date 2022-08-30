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
    class InsertFile: Factory {
        override class var zilNames: [String] {
            ["INSERT-FILE"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.exactly(1)),
                .haveType(.string),
            ])
        }

        override func process() throws -> Symbol {
            let filename = symbols[0]

            return .statement(
                code: { _ in
                    "// Insert file \(filename.code)"
                },
                type: .comment,
                confidence: .certain
            )
        }
    }
}
