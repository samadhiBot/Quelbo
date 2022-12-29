//
//  PrintDescription.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PRINTD](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.43v86uo)
    /// function.
    class PrintDescription: Factory {
        override class var zilNames: [String] {
            ["PRINTD"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1)),
                .haveType(.object)
            )
        }

        override func process() throws -> Symbol {
            let string = symbols[0]

            return .statement(
                code: { _ in
                    "output(\(string.code).description)"
                },
                type: .void
            )
        }
    }
}
