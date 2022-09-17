//
//  IsZero.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ZERO?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1wjtbr7)
    /// function.
    class IsZero: Factory {
        override class var zilNames: [String] {
            ["0?", "ZERO?"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.exactly(1)),
                .haveType(.int)
            ])
        }

        var function: String {
            "isZero"
        }

        override func process() throws -> Symbol {
            let function = function
            let value = symbols[0]

            return .statement(
                code: { _ in
                    "\(value.code).\(function)"
                },
                type: .bool
            )
        }
    }
}
