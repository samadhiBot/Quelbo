//
//  Room.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/12/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ROOM](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.13qzunr)
    /// function.
    class Room: Object {
        override class var zilNames: [String] {
            ["ROOM"]
        }

        override var category: Category {
            .rooms
        }

        override var typeName: String {
            "Room"
        }
    }
}
