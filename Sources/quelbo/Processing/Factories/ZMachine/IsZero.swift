//
//  IsZero.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ZERO?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1wjtbr7)
    /// function.
    class IsZero: ZMachineFactory {
        override class var zilNames: [String] {
            ["0?", "ZERO?"]
        }

        override var parameters: Parameters {
            .one(.int)
        }

        override var returnType: Symbol.DataType {
            .bool
        }

        var function: String {
            "isZero"
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0)).\(function)",
                type: .bool,
                children: symbols
            )
        }
    }
}
