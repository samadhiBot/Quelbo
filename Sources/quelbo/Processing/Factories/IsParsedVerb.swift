//
//  IsParsedVerb.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/23/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the Fizmo `isParsedVerb` function.
    class IsParsedVerb: Factory {
        override class var zilNames: [String] {
            ["VERB?"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(1))
            )

            try? symbols.assert(
                .haveType(.verb)
            )
        }

        override func process() throws -> Symbol {
            let values = symbols.nonCommentSymbols.map { ".\($0.handle)" }

            return .statement(
                code: { _ in
                    "isParsedVerb(\(values.values(.commaSeparatedNoTrailingComma)))"
                },
                type: .bool
            )
        }
    }
}
