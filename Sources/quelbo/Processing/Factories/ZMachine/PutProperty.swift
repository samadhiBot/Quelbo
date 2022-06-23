//
//  PutProperty.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PUTP](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.48zs1w5)
    /// function.
    class PutProperty: ZMachineFactory {
        override class var zilNames: [String] {
            ["PUTP"]
        }

        override class var parameters: Parameters {
            .three(.object, .property(.unknown), .unknown)
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0).code).\(try symbol(1).code) = \(try symbol(2).code)",
                type: try symbol(2).type,
                children: symbols
            )
        }
    }
}
