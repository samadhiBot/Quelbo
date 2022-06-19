//
//  Verify.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [VERIFY](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2ye626w)
    /// function.
    class Verify: ZMachineFactory {
        override class var zilNames: [String] {
            ["VERIFY"]
        }

        override class var parameters: Parameters {
            .zero
        }

        override class var returnType: Symbol.DataType {
            .void
        }

        override func process() throws -> Symbol {
            Symbol(
                "verify()",
                type: .void
            )
        }
    }
}
