//
//  IsAssigned.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ASSIGNED?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.393x0lu)
    /// function.
    class IsAssigned: ZMachineFactory {
        override class var zilNames: [String] {
            ["ASSIGNED?"]
        }

        override class var parameters: Parameters {
            .one(.variable(.unknown))
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0).code).isAssigned",
                type: .bool,
                children: symbols
            )
        }
    }
}
