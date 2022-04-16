//
//  Crlf.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [CRLF](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3e8gvnb)
    /// function.
    class Crlf: ZMachineFactory {
        override class var zilNames: [String] {
            ["CRLF"]
        }

        override class var parameters: Parameters {
            .zero
        }

        override class var returnType: Symbol.DataType {
            .void
        }

        override func process() throws -> Symbol {
            Symbol(
                "output(carriageReturn)",
                type: .void,
                children: symbols
            )
        }
    }
}
