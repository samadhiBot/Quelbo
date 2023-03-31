//
//  IsCurrentRoom.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/23/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the Fizmo `isCurrentRoom` function.
    class IsCurrentRoom: IsParsedDirectObject {
        override class var zilNames: [String] {
            ["ROOM?"]
        }

        override func process() throws -> Symbol {
            let values = symbols.nonCommentSymbols.map(\.globalID)

            return .statement(
                code: { _ in
                    "isCurrentRoom(\(values.values(.commaSeparatedNoTrailingComma)))"
                },
                type: .bool
            )
        }
    }
}
