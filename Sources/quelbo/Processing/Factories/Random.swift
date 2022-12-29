//
//  Random.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/23/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [RANDOM](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.13acmbr)
    /// function.
    class Random: Factory {
        override class var zilNames: [String] {
            ["RANDOM"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1)),
                .haveType(.int)
            )
        }

        override func process() throws -> Symbol {
            let maximum = symbols[0]

            return .statement(
                code: { _ in
                    ".random(\(maximum.code))"
                },
                type: .int
            )
        }
    }
}
