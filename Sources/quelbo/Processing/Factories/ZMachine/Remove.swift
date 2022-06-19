//
//  Remove.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [REMOVE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.22faf7d)
    /// function.
    class Remove: ZMachineFactory {
        override class var zilNames: [String] {
            ["REMOVE"]
        }

        override class var parameters: Parameters {
            .one(.object)
        }

        override class var returnType: Symbol.DataType {
            .void
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0).code).remove()",
                type: .void,
                children: symbols
            )
        }
    }
}
