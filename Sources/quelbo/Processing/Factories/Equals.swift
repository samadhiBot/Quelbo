//
//  Equals.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [EQUAL?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2vor4mt)
    /// function.
    class Equals: Factory {
        override class var zilNames: [String] {
            ["=?", "==?", "EQUAL?"]
        }

        var function: String {
            "equals"
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(2)),
                .haveCommonType
            )
        }

        override func evaluate() throws -> Symbol {
            guard let firstElement = symbols.first?.evaluation else {
                return .false
            }
            for element in symbols.nonCommentSymbols.map(\.evaluation) {
                guard element == firstElement else { return .false }
            }
            return .true
        }

        override func process() throws -> Symbol {
            let first = symbols[0]
            let function = function
            let rest = Array(symbols[1..<symbols.count])

            return .statement(
                code: { _ in
                    "\(first.chainingID).\(function)(\(rest.handles(.commaSeparatedNoTrailingComma)))"
                },
                type: .bool
            )
        }
    }
}
