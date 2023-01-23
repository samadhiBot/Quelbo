//
//  Modulo.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/18/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [MOD](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.20gsq1z)
    /// function.
    class Modulo: Arithmetic {
        override class var zilNames: [String] {
            ["MOD"]
        }

        override var operation: Operation {
            .modulo
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2)),
                .haveType(.int)
            )
        }
    }
}
