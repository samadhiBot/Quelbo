//
//  GreaterThanOrEqual.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [G=?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2bxgwvm)
    /// function.
    class GreaterThanOrEqual: Equals {
        override class var zilNames: [String] {
            ["G=?"]
        }

        override var function: String {
            "greaterThanOrEquals"
        }

        override var parameters: Parameters {
            .twoOrMore(.int)
        }
    }
}
