//
//  ClearFlag.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [FCLEAR](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.zdd80z)
    /// function.
    class ClearFlag: SetFlag {
        override class var zilNames: [String] {
            ["FCLEAR"]
        }

        override var value: Bool { false }
    }
}
