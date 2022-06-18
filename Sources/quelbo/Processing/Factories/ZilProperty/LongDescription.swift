//
//  LongDescription.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `LDESC` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class LongDescription: ZilPropertyFactory {
        override class var zilNames: [String] {
            ["LDESC"]
        }

        override class var parameters: Parameters {
            .one(.string)
        }

        override class var returnType: Symbol.DataType {
            .string
        }

        override func process() throws -> Symbol {
            Symbol(
                id: .id("longDescription"),
                code: "longDescription: \(try symbol(0).code)",
                type: Self.returnType,
                children: symbols
            )
        }
    }
}
