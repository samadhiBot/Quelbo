//
//  IsParsedDirectObject.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/23/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the Fizmo `isParsedDirectObject` function.
    class IsParsedDirectObject: Factory {
        override class var zilNames: [String] {
            ["PRSO?"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(1))
            )

            try? symbols.assert(
                .haveType(.object)
            )
        }

        override func process() throws -> Symbol {
            let values = symbols.nonCommentSymbols.map(\.globalID)

            return .statement(
                code: { _ in
                    "isParsedDirectObject(\(values.values(.commaSeparatedNoTrailingComma)))"
                },
                type: .bool
            )
        }
    }
}
