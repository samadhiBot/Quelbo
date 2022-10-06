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
    class Synonyms: Factory {
        override class var factoryType: FactoryType {
            .property
        }

        override class var zilNames: [String] {
            ["SYNONYM"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveType(.string)
            )
        }

        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "synonyms" },
                    type: .array(.string)
                )
            }

            let synonyms = symbols.map(\.code.quoted)

            return .statement(
                id: "synonyms",
                code: { _ in
                    "synonyms: [\(synonyms.values(.commaSeparated))]"
                },
                type: .array(.string)
            )
        }
    }
}
