//
//  IsOne.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [isOne](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4gjguf0)
    /// function.
    class IsOne: IsZero {
        override class var zilNames: [String] {
            ["1?"]
        }

        override var function: String {
            "isOne"
        }
    }
}
