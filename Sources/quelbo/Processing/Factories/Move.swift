//
//  Move.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [MOVE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1er0t5e)
    /// function.
    class Move: Factory {
        override class var zilNames: [String] {
            ["MOVE"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2)),
                .haveType(.object)
            )

            try symbols[1].assert(
                .hasReturnValue
            )
        }

        override func process() throws -> Symbol {
            let object = symbols[0]
            let location = symbols[1]

            return .statement(
                code: { _ in
                    "\(object.code).move(to: \(location.handle))"
                },
                type: .void
            )
        }
    }
}
