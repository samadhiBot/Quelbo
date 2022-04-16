//
//  TakeValue.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `TVALUE` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class TakeValue: ZilPropertyFactory {
        override class var zilNames: [String] {
            ["TVALUE"]
        }

        override class var parameters: Parameters {
            .one(.int)
        }

        override class var returnType: Symbol.DataType {
            .int
        }

        override func process() throws -> Symbol {
            Symbol(
                id: "takeValue",
                code: "takeValue: \(try symbol(0))",
                type: Self.returnType,
                children: symbols
            )
        }
    }
}
