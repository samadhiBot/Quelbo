//
//  ReturnFatal.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [RFATAL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3eze420)
    /// function.
    class ReturnFatal: ZMachineFactory {
        override class var zilNames: [String] {
            ["RFATAL"]
        }

        override class var parameters: Parameters {
            .zero
        }

        override class var returnType: Symbol.DataType {
            .void
        }

        override func process() throws -> Symbol {
            Symbol(
                "returnFatal()",
                type: .void
            )
        }
    }
}
