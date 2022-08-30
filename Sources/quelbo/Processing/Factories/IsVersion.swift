//
//  IsVersion.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [VERSION?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1rf9gpq)
    /// function.
    class IsVersion: Condition {
        override class var zilNames: [String] {
            ["VERSION?"]
        }

        override var conditionalFactory: Factory.Type {
            Factories.IsVersionConditional.self
        }
    }
}
