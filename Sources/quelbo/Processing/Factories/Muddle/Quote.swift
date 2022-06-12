//
//  Quote.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/12/22.
//

import Foundation

extension Factories {
    /// A symbol factory for Zil
    /// [QUOTE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1c1lvlb).
    class Quote: MuddleFactory {
        override func process() throws -> Symbol {
            try symbol(0)
        }
    }
}
