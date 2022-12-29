//
//  Remove.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [REMOVE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.22faf7d)
    /// function.
    class Remove: Factory {
        override class var zilNames: [String] {
            ["REMOVE"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1)),
                .haveType(.object)
            )
        }

        override func process() throws -> Symbol {
            let object = symbols[0]

            return .statement(
                code: { _ in
                    "\(object.code).remove()"
                },
                type: .void
            )
        }
    }
}
