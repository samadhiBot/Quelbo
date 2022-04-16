//
//  GetProperty.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GETP](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1q7ozz1)
    /// function.
    class GetProperty: ZMachineFactory {
        override class var zilNames: [String] {
            ["GETP"]
        }

        override class var parameters: Parameters {
            .two(.object, .property)
        }

        override class var returnType: Symbol.DataType {
            .unknown
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0)).\(try symbol(1))",
                type: try symbol(1).type,
                children: symbols
            )
        }
    }
}
