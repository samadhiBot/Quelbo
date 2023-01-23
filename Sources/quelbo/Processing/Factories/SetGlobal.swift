//
//  SetGlobal.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/12/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [SETG](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.mp4kgn)
    /// function.
    class SetGlobal: SetLocal {
        override class var factoryType: Factories.FactoryType {
            .zCode
        }

        override class var zilNames: [String] {
            ["SETG"]
        }

        override func processSymbols() throws {
            try super.processSymbols()

            try symbols[0].assert(
                .hasCategory(.globals)
            )
        }
    }
}
