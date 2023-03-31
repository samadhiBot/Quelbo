//
//  IsParsedIndirectObject.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/23/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the Fizmo `isParsedIndirectObject` function.
    class IsParsedIndirectObject: IsParsedDirectObject {
        override class var zilNames: [String] {
            ["PRSI?"]
        }

        override func process() throws -> Symbol {
            let values = symbols.nonCommentSymbols.map(\.globalID)

            return .statement(
                code: { _ in
                    "isParsedIndirectObject(\(values.values(.commaSeparatedNoTrailingComma)))"
                },
                type: .bool
            )
        }
    }
}
