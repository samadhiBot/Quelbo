//
//  Or.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [OR](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1s66p4f)
    /// function.
    class Or: And {
        override class var zilNames: [String] {
            ["OR"]
        }

        override var function: String {
            "or"
        }
    }
}
