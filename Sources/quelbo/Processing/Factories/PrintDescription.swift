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
            .statement(
                code: {
                    "output(\($0.payload.symbols[0].chainingID).description)"
                },
                type: .void,
                payload: .init(symbols: symbols)
            )
        }
    }
}
