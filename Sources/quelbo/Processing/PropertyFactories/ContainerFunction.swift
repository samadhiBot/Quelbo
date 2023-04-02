//
//  ContainerFunction.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/1/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `CONTFCN` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class ContainerFunction: Action {
        override class var zilNames: [String] {
            ["CONTFCN"]
        }

        override var propertyName: String {
            "containerFunction"
        }
    }
}
