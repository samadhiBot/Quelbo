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

        override func processTokens() throws {
            self.symbols = try symbolizeAtomsToStrings(tokens)
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(2))
            )
        }

        override func process() throws -> Symbol {
            let word = symbols[0].code.replacingOccurrences(of: "\"", with: "")
            let synonyms = symbols[1..<symbols.count]
                .map(\.code)
                .sorted()

            return .statement(
                id: "synonym:\(word)",
                code: { _ in
                    """
                    Syntax.set("\(word)", synonyms: [\(synonyms.values(.commaSeparated))])
                    """
                },
                type: .string,
                category: .syntax,
                isCommittable: true
            )
        }
    }
}
