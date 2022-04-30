//
//  IsIn.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [IN?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.is565v)
    /// function.
    class IsIn: ZMachineFactory {
        override class var zilNames: [String] {
            ["IN?"]
        }

        override class var parameters: Parameters {
            .two(.object, .object)
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0)).isIn(\(try symbol(1)))",
                type: .bool,
                children: symbols
            )
        }
    }
}
