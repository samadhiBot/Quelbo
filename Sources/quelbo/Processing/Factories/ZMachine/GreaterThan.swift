//
//  GreaterThan.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GRTR?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3ws6mnt)
    /// function.
    class GreaterThan: Equals {
        override class var zilNames: [String] {
            ["G?", "GRTR?"]
        }

        override var function: String {
            "greaterThan"
        }

        override var parameters: Parameters {
            .twoOrMore(.int)
        }
    }
}
