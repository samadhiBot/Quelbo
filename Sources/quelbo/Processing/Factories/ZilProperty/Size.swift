//
//  Size.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `SIZE` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Size: ZilPropertyFactory {
        override class var zilNames: [String] {
            ["SIZE"]
        }

        override class var parameters: Parameters {
            .one(.int)
        }

        override class var returnType: Symbol.DataType {
            .int
        }

        override func process() throws -> Symbol {
            Symbol(
                id: "size",
                code: "size: \(try symbol(0))",
                type: Self.returnType,
                children: symbols
            )
        }
    }
}
