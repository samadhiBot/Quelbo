//
//  Nth.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [NTH](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.odc9jc)
    /// function.
    class Nth: MuddleFactory {
        override class var zilNames: [String] {
            ["NTH"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .two(.array(.unknown), .int)
        }

        override func process() throws -> Symbol {
            let values = try symbol(0)
            let index = try symbol(1)

            return Symbol(
                "\(values).nthElement(\(index))",
                type: values.children.commonType() ?? values.type,
                children: symbols
            )
        }
    }
}
