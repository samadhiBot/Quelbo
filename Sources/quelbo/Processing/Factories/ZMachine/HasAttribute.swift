//
//  HasAttribute.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [FSET?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2xn8ts7)
    /// function.
    class HasAttribute: ZMachineFactory {
        override class var zilNames: [String] {
            ["FSET?"]
        }

        override class var parameters: Parameters {
            .two(.object, .bool)
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0).code).hasAttribute(\(try symbol(1).code))",
                type: .bool,
                children: symbols
            )
        }
    }
}
