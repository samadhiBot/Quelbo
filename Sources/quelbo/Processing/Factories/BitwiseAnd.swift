//
//  BitwiseAnd.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [BAND](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.488uthg)
    /// function.
    class BitwiseAnd: And {
        override class var zilNames: [String] {
            ["BAND", "ANDB"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(1)),
                .haveType(.int)
            )
        }

        override var function: String {
            "bitwiseAnd"
        }
    }
}
