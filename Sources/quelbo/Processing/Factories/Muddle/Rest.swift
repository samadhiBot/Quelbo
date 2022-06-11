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
    class Rest: MuddleFactory {
        override class var zilNames: [String] {
            ["REST"]
        }

        override func process() throws -> Symbol {
            let structure = try symbol(0)
            let count = (try? symbol(1)) ?? Symbol("")

            return Symbol(
                "\(structure.code).rest(\(count.code))",
                type: structure.type,
                children: symbols
            )
        }
    }
}
