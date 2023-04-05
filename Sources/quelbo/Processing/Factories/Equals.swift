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
            let function = function

            return .statement(
                code: {
                    var symbols = $0.payload.symbols
                    let first = symbols.removeFirst()

                    return """
                        \(first.chainingID)\
                        .\(function)\
                        (\(symbols.handles(.commaSeparatedNoTrailingComma)))
                        """
                },
                type: .bool,
                payload: .init(
                    symbols: symbols
                )
            )
        }
    }
}
