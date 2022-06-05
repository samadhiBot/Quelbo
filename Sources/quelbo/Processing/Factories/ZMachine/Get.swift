//
//  Get.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GET](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.r2r73f) and
    /// [GETB](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3b2epr8)
    /// functions.
    class Get: ZMachineFactory {
        override class var zilNames: [String] {
            ["GET", "GETB"]
        }

        override class var parameters: Parameters {
            .two(.table, .int)
        }

        override class var returnType: Symbol.DataType {
            .zilElement
        }

        override func process() throws -> Symbol {
            let table = try symbol(0)
            let offset = try symbol(1)

            return Symbol(
                "try \(table).get(at: \(offset))",
                type: .zilElement,
                children: symbols
            )
        }
    }
}
