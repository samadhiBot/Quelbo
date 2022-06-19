//
//  IncrementGreaterThan.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [IGRTR?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.23muvy2)
    /// function.
    class IncrementGreaterThan: ZMachineFactory {
        override class var zilNames: [String] {
            ["IGRTR?"]
        }

        override class var parameters: Parameters {
            .two(.variable(.int), .int)
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        override func process() throws -> Symbol {
            let variable = try symbol(0).with(meta: [.mutating(true)])
            let value = try symbol(1)
            
            return Symbol(
                "\(variable.code).increment().isGreaterThan(\(value.code))",
                type: .bool,
                children: [variable, value]
            )
        }
    }
}
