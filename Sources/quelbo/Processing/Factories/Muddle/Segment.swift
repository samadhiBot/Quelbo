//
//  Segment.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/3/22.
//

import Foundation

extension Factories {
    /// A symbol factory for Zil
    /// [Segments](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.9p1vu0r47dql).
    class Segment: MuddleFactory {
        override func process() throws -> Symbol {
            try symbol(0)
        }
    }
}
