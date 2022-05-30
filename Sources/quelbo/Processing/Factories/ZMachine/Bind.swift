//
//  Bind.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/24/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [BIND](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.12jfdx2)
    /// function.
    class Bind: ProgramBlock {
        override class var zilNames: [String] {
            ["BIND"]
        }

        override func processTokens() throws {
            self.pro = try BlockProcessor(tokens, in: .blockWithoutDefaultActivation, with: types)
        }
    }
}
