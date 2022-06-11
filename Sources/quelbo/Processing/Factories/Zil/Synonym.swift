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
    class Synonym: ZilFactory {
        override class var zilNames: [String] {
            [
                "SYNONYM",
                "ADJ-SYNONYM",
                "DIR-SYNONYM",
                "PREP-SYNONYM",
                "VERB-SYNONYM",
            ]
        }

        override class var parameters: SymbolFactory.Parameters {
            .twoOrMore(.string)
        }

        override func process() throws -> Symbol {
            guard let word = symbols.shift() else {
                throw Error.missingInitialSynonymWord(symbols)
            }
            let synonyms = symbols.quoted.sorted.codeValues(.commaSeparated)

            let symbol = Symbol(
                id: .init(stringLiteral: "<Synonyms:\(word.code)>"),
                code: """
                Syntax.set("\(word.code)", synonyms: \(synonyms))
                """,
                type: .string,
                category: .syntax
            )
            try Game.commit(symbol)
            return symbol
        }
    }
}

// MARK: - Errors

extension Factories.Synonym {
    enum Error: Swift.Error {
        case missingInitialSynonymWord([Symbol])
    }
}
