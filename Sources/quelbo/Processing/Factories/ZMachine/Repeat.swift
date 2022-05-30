//
//  Repeat.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [REPEAT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.hkkpf6)
    /// function.
    class Repeat: ProgramBlock {
        override class var zilNames: [String] {
            ["REPEAT"]
        }

        override func processTokens() throws {
            self.pro = try BlockProcessor(tokens, in: .repeatingWithDefaultActivation, with: types)
        }
    }
}
