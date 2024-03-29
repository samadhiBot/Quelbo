//
//  Rest.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [REST](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.49gfa85)
    /// function.
    class Rest: Back {
        override class var zilNames: [String] {
            ["REST"]
        }

        override var method: String {
            "rest"
        }
    }
}
