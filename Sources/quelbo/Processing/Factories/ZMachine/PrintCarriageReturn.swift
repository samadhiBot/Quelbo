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
            Symbol(
                """
                    output(\(try symbol(0)))
                    output("\\n")
                    """,
                type: .void,
                children: symbols
            )
        }
    }
}
