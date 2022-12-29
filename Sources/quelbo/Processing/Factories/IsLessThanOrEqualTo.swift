//
//  IsLessThanOrEqualTo.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [L=?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4fbwdob)
    /// function.
    class IsLessThanOrEqualTo: Equals {
        override class var zilNames: [String] {
            ["L=?"]
        }

        override var function: String {
            "isLessThanOrEqualTo"
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(2)),
                .haveType(.int)
            )
        }
    }
}
