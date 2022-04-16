//
//  PrintDescription.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PRINTD](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.43v86uo)
    /// function.
    class PrintDescription: ZMachineFactory {
        override class var zilNames: [String] {
            ["PRINTD"]
        }

        override class var parameters: Parameters {
            .one(.object)
        }

        override class var returnType: Symbol.DataType {
            .void
        }

        override func process() throws -> Symbol {
            Symbol(
                "output(\(try symbol(0)).description)",
                type: .void,
                children: symbols
            )
        }
    }
}
