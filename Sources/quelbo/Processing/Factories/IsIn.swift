//
//  IsIn.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [IN?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.is565v)
    /// function.
    class IsIn: Factory {
        override class var zilNames: [String] {
            ["IN?"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2)),
                .haveType(.object)
            )
        }

        override func process() throws -> Symbol {
            let child = symbols[0]
            let parent = symbols[1]

            return .statement(
                code: { _ in
                    "\(child.code).isIn(\(parent.handle))"
                },
                type: .bool
            )
        }
    }
}
