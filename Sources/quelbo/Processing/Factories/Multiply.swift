//
//  Multiply.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [MUL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.434ayfz)
    /// function.
    class Multiply: Add {
        override class var zilNames: [String] {
            ["*", "MUL"]
        }

        override var function: String {
            "multiply"
        }
    }
}
