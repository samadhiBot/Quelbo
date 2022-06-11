//
//  Not.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [NOT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3d0wewm)
    /// function.
    class Not: ZMachineFactory {
        override class var zilNames: [String] {
            ["NOT"]
        }

        override class var parameters: Parameters {
            .one(.bool)
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        override func process() throws -> Symbol {
            Symbol(
                "!\(try symbol(0).code)",
                type: .bool,
                children: symbols
            )
        }
    }
}
