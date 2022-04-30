//
//  Synonyms.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `SYNONYM` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Synonyms: ZilPropertyFactory {
        override class var zilNames: [String] {
            ["SYNONYM"]
        }

        override class var parameters: Parameters {
            .oneOrMore(.string)
        }

        override class var returnType: Symbol.DataType {
            .array(.string)
        }

        override func process() throws -> Symbol {
            Symbol(
                id: "synonyms",
                code: "synonyms: \(symbols.quoted.code)",
                type: Self.returnType,
                children: symbols.map { $0.with(literal: true) }
            )
        }
    }
}
