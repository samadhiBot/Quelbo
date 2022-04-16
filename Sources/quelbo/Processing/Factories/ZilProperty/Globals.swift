//
//  Globals.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `GLOBAL` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Globals: ZilPropertyFactory {
        override class var zilNames: [String] {
            ["GLOBAL"]
        }

        override class var parameters: Parameters {
            .oneOrMore(.object)
        }

        override class var returnType: Symbol.DataType {
            .array(.object)
        }

        override func process() throws -> Symbol {
            Symbol(
                id: "globals",
                code: "globals: \(symbols.code)",
                type: Self.returnType,
                children: symbols
            )
        }
    }
}
