//
//  DecrementLessThan.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [DLESS?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.35xuupr)
    /// function.
    class DecrementLessThan: ZMachineFactory {
        override class var zilNames: [String] {
            ["DLESS?"]
        }

        override class var parameters: Parameters {
            .two(.property, .int)
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0)).decrement().lessThan(\(try symbol(1)))",
                type: .bool,
                children: symbols
            )
        }
    }
}
