//
//  Crlf.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [CRLF](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3e8gvnb)
    /// function.
    class Crlf: Factory {
        override class var zilNames: [String] {
            ["CRLF"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(0)))
        }

        override func process() throws -> Symbol {
            .statement(
                code: { _ in
                    #"output("\n")"#
                },
                type: .void
            )
        }
    }
}
