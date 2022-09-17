//
//  Ascii.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ASCII](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3whwml4)
    /// function.
    class Ascii: Factory {
        override class var zilNames: [String] {
            ["ASCII"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.exactly(1)),
                .haveType(.oneOf([.int, .string])),
            ])
        }

        override func process() throws -> Symbol {
            let value = symbols[0]

            return .statement(
                code: { _ in
                    "\(value.code).ascii"
                },
                type: value.type == .int ? .string : .int
            )
        }
    }
}
