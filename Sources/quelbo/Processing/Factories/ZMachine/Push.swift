//
//  Push.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PUSH](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.pv6qcq)
    /// function.
    class Push: ZMachineFactory {
        override class var zilNames: [String] {
            ["PUSH"]
        }

        override class var parameters: Parameters {
            .one(.unknown)
        }

        override func process() throws -> Symbol {
            Symbol(
                "push(\(symbols.codeValues()))",
                type: .void
            )
        }
    }
}
