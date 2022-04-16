//
//  Print.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/2/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PRINT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.kqmvb9),
    /// [PRINTB](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.34qadz2), and
    /// [PRINTI](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.y5sraa)
    /// functions.
    class Print: ZMachineFactory {
        override class var zilNames: [String] {
            ["PRINT", "PRINTB", "PRINTI"]
        }

        override class var parameters: Parameters {
            .one(.string)
        }

        override class var returnType: Symbol.DataType {
            .void
        }

        override func process() throws -> Symbol {
            Symbol(
                "output(\(try symbol(0)))",
                type: .void,
                children: symbols
            )
        }
    }
}
