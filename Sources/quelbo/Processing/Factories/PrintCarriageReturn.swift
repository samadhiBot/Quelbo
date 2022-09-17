//
//  PrintCarriageReturn.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PRINTR](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1xaqk5w)
    /// function.
    class PrintCarriageReturn: Print {
        override class var zilNames: [String] {
            ["PRINTR"]
        }

        override func process() throws -> Symbol {
            let string = symbols[0]

            return .statement(
                code: { _ in
                    """
                    output(\(string.code))
                    output("\\n")
                    """
                },
                type: .void
            )
        }
    }
}
