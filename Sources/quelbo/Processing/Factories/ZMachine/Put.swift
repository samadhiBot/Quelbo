//
//  Put.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/1/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PUT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.39uu90j) and
    /// [PUTB](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1p04j8c)
    /// functions.
    class Put: ZMachineFactory {
        override class var zilNames: [String] {
            ["PUT", "PUTB"]
        }

        override class var parameters: Parameters {
            .three(.table, .int, .unknown)
        }

        override func process() throws -> Symbol {
            let table = try symbol(0)
            let offset = try symbol(1)
            let value = try symbol(2)

            return Symbol(
                "try \(table.code).put(element: \(value.code), at: \(offset.code))",
                type: value.type,
                children: symbols
            )
        }
    }
}
