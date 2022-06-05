//
//  Define.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/5/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [DEFINE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.440mph5j49mp)
    /// function.
    class Define: Routine {
        override class var zilNames: [String] {
            ["DEFINE"]
        }

        override var typeName: String {
            "function"
        }
    }
}
