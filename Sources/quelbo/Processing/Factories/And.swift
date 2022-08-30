//
//  And.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [AND](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3utoxif)
    /// function.
    class And: Factory {
        override class var zilNames: [String] {
            ["AND"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.atLeast(1)),
                .haveCommonType
            ])
        }

        var function: String {
            "and"
        }

        override func process() throws -> Symbol {
            let function = function
            let operands = symbols

            return .statement(
                code: { _ in
                    ".\(function)(\(operands.codeValues(.commaSeparatedNoTrailingComma)))"
                },
                type: operands.first?.type,
                confidence: .certain
            )
        }
    }
}
