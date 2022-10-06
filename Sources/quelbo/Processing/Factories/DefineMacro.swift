//
//  DefineMacro.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/2/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [DEFMAC](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.206ipza)
    /// function.
    class DefineMacro: Routine {
        override class var zilNames: [String] {
            ["DEFMAC"]
        }

        override var isMacro: Bool {
            true
        }
    }
}
