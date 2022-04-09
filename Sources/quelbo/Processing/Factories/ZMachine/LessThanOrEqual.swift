//
//  LessThanOrEqual.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [L=?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4fbwdob)
    /// function.
    class LessThanOrEqual: Equals {
        override class var zilNames: [String] {
            ["L=?"]
        }

        override var function: String {
            "lessThanOrEquals"
        }

        override var parameters: Parameters {
            .twoOrMore(.int)
        }
    }
}
