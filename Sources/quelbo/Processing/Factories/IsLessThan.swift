//
//  IsLessThan.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LESS?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1vc8v0i)
    /// function.
    class IsLessThan: Equals {
        override class var zilNames: [String] {
            ["L?", "LESS?"]
        }

        override var function: String {
            "isLessThan"
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.atLeast(2)),
                .haveType(.int)
            ])
        }
    }
}
