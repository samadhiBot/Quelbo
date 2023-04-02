//
//  DescriptionFunction.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `DESCFCN` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class DescriptionFunction: Action {
        override class var zilNames: [String] {
            ["DESCFCN"]
        }

        override var propertyName: String {
            "descriptionFunction"
        }
    }
}
