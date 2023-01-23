//
//  Divide.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [DIV](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3hej1je)
    /// function.
    class Divide: Arithmetic {
        override class var zilNames: [String] {
            ["/", "DIV"]
        }

        override var operation: Operation {
            .divide
        }
    }
}
