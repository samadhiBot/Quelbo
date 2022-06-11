//
//  Location.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `IN` / `LOC` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Location: ZilPropertyFactory {
        override class var zilNames: [String] {
            ["IN", "LOC"]
        }

        override class var parameters: Parameters {
            .one(.object)
        }

        override class var returnType: Symbol.DataType {
            .object
        }

        override func process() throws -> Symbol {
            Symbol(
                id: "location",
                code: "location: \(try symbol(0).code)",
                type: Self.returnType,
                children: symbols
            )
        }
    }
}
