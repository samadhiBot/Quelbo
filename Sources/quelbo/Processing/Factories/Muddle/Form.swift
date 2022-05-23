//
//  Form.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/3/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [FORM](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.xvir7l)
    /// function.
    class Form: MuddleFactory {
        override class var zilNames: [String] {
            ["FORM"]
        }

        override func processTokens() throws {
            self.symbols = [try symbolizeForm(tokens)]
        }

        override func process() throws -> Symbol {
            try symbol(0)
        }
    }
}
