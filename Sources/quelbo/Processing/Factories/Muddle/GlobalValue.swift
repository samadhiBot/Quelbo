//
//  GlobalValue.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GVAL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2250f4o)
    /// function.
    class GlobalValue: MuddleFactory {
        override class var zilNames: [String] {
            ["GVAL"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .one(.unknown)
        }

        override func process() throws -> Symbol {
            try symbol(0)
        }
    }
}
