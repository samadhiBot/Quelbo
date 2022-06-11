//
//  PropertyDefault.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PROPDEF](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1kc7wiv)
    /// function.
    class PropertyDefault: Constant {
        override class var zilNames: [String] {
            ["PROPDEF"]
        }

        override var codeBlock: String {
            "setPropertyDefault(\(nameSymbol.code), \(valueSymbol.code))"
        }
    }
}
