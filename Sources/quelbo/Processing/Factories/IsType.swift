//
//  IsType.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [TYPE?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2lfnejv)
    /// function.
    class IsType: Factory {
        override class var zilNames: [String] {
            ["TYPE?"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2))
            )
        }

        override func process() throws -> Symbol {
            let value = symbols[0]
            let type = symbols[1]

            return .statement(
                code: { _ in
                    "\(value.code).isType(\(type.code))"
                },
                type: .bool,
                confidence: .certain
            )
        }
    }
}
