//
//  Random.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/23/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [RANDOM](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.13acmbr)
    /// function.
    class Random: ZMachineFactory {
        override class var zilNames: [String] {
            ["RANDOM"]
        }

        override class var parameters: Parameters {
            .one(.int)
        }

        override class var returnType: Symbol.DataType {
            .int
        }

        override func process() throws -> Symbol {
            Symbol(
                ".random(\(try symbol(0)))",
                type: .int,
                children: symbols
            )
        }
    }
}
