//
//  Synonym.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/4/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [SYNONYM](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.s1gwiysqrg1z)
    /// function.
    class Synonym: Factory {
        override class var factoryType: FactoryType {
            .mdl
        }

        override class var zilNames: [String] {
            [
                "SYNONYM",
                "ADJ-SYNONYM",
                "DIR-SYNONYM",
                "PREP-SYNONYM",
                "VERB-SYNONYM",
            ]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.atLeast(2)),
                .haveType(.string)
            ])
        }

        override func process() throws -> Symbol {
            let word = symbols[0]
            let synonyms = symbols[1..<symbols.count]
                .map(\.code.quoted)
                .sorted()

            return .statement(
                code: { _ in
                    """
                    Syntax.set("\(word.code)", synonyms: [\(synonyms.values(.commaSeparated))])
                    """
                },
                type: .string,
                category: .syntax,
                isCommittable: true
            )
        }
    }
}
