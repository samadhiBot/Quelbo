//
//  RaiseError.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ERROR](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3q5sasy)
    /// function.
    class RaiseError: Factory {
        override class var zilNames: [String] {
            ["ERROR"]
        }

        override func process() throws -> Symbol {
            let values = symbols

            return .statement(
                code: { _ in
                    "throw FizmoError.mdlError(\(values.codeValues(.commaSeparated)))"
                },
                type: .void
            )
        }
    }
}
