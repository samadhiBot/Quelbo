//
//  BitwiseOr.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [BOR](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3mj2wkv)
    /// function.
    class BitwiseOr: And {
        override class var zilNames: [String] {
            ["BOR", "ORB"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.atLeast(1)),
                .haveType(.int)
            ])
        }

        override var function: String {
            "bitwiseOr"
        }
    }
}
