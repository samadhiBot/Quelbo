//
//  Adjectives.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `ADJECTIVE` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Adjectives: ZilPropertyFactory {
        override class var zilNames: [String] {
            ["ADJECTIVE"]
        }

        override class var parameters: Parameters {
            .oneOrMore(.string)
        }

        override class var returnType: Symbol.DataType {
            .array(.string)
        }

        override func process() throws -> Symbol {
            Symbol(
                id: .id("adjectives"),
                code: "adjectives: [\(symbols.quoted.codeValues(.commaSeparated))]",
                type: Self.returnType,
                children: symbols.map { $0.with(meta: [.isLiteral]) }
            )
        }
    }
}
