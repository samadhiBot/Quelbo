//
//  IsEmpty.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [EMPTY?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2dlolyb)
    /// function.
    class IsEmpty: Factory {
        override class var zilNames: [String] {
            ["EMPTY?"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1))
            )
        }

        override func process() throws -> Symbol {
            let container = symbols[0]

            return .statement(
                code: { _ in
                    "\(container.code).isEmpty"
                },
                type: .bool
            )
        }
    }
}
