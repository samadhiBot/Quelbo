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

        @discardableResult
        override func process() throws -> Symbol {
            let variable = symbols[0]
            let value = symbols[1]

            return .statement(
                code: { _ in
                    "setPropertyDefault(\(variable.code), \(value.code))"
                },
                type: variable.type
            )
        }
    }
}
