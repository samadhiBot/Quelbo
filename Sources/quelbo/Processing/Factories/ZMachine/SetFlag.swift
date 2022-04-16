//
//  SetFlag.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [FSET](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4ihyjke)
    /// function.
    class SetFlag: ZMachineFactory {
        override class var zilNames: [String] {
            ["FSET"]
        }

        override class var parameters: Parameters {
            .two(.object, .bool)
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        var value: Bool { true }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0)).\(try symbol(1)) = \(value)",
                type: .void,
                children: symbols
            )
        }
    }
}
