//
//  IsVerb.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/2/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Fizmo `isVerb` function.
    class IsVerb: Factory {
        override class var zilNames: [String] {
            ["VERB?"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(1)),
                .haveType(.verb)
            )
        }

        override func process() throws -> Symbol {
            let values = symbols.map { ".\($0.handle)" }

            return .statement(
                code: { _ in
                    "isVerb(\(values.values(.commaSeparatedNoTrailingComma)))"
                },
                type: .bool
            )
        }
    }
}
