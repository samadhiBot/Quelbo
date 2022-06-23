//
//  IsNot.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [NOT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3d0wewm)
    /// function.
    class IsNot: ZMachineFactory {
        override class var zilNames: [String] {
            ["NOT"]
        }

        override class var parameters: Parameters {
            .one(.unknown)
        }

        override func process() throws -> Symbol {
            Symbol(
                ".isNot(\(try symbol(0).code))",
                type: .bool,
                children: symbols
            )
        }
    }
}
