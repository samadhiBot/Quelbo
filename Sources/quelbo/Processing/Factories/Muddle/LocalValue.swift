//
//  LocalValue.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/3/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LVAL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3bj1y38)
    /// function.
    class LocalValue: MuddleFactory {
        override class var zilNames: [String] {
            ["LVAL"]
        }

        override func process() throws -> Symbol {
            try symbol(0)
        }
    }
}
