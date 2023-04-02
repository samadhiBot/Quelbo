//
//  AdventurerFunction.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/13/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the `ADVFCN` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class AdventurerFunction: Action {
        override class var zilNames: [String] {
            ["ADVFCN"]
        }

        override var propertyName: String {
            "adventurerFunction"
        }
    }
}
