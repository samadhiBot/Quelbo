//
//  DescriptionFunction.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `DESCFCN` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class DescriptionFunction: PropertyFactory {
        override class var zilNames: [String] {
            ["DESCFCN"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.between(0...1)),
                .haveType(.routine),
            ])
        }

        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "descriptionFunction" },
                    type: .routine,
                    confidence: .certain
                )
            }
            let function = symbols[0]

            return .statement(
                id: "descriptionFunction",
                code: { _ in
                    "descriptionFunction: \(function.code)"
                },
                type: .routine,
                confidence: .certain
            )
        }
    }
}
