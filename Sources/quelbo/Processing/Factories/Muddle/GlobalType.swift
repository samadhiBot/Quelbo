//
//  GlobalType.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GDECL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.k62wjra3zbsy)
    /// function.
    class GlobalType: DeclareType {
        override class var zilNames: [String] {
            ["GDECL"]
        }

        override var idValue: Symbol.Identifier {
            "<GlobalType>"
        }

        override var isGlobal: Bool {
            true
        }
    }
}
