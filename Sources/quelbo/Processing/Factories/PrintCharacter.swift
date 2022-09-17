//
//  PrintCharacter.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PRINTC](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1jvko6v) and
    /// [PRINTU](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2wfod1i)
    /// functions.
    class PrintCharacter: Print {
        override class var zilNames: [String] {
            ["PRINTC", "PRINTU"]
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
                    switch value.type {
                    case .int:
                        return "output(utf8: \(value.code))"
                    default:
                        return "output(\(value.code))"
                    }
                },
                type: .void
            )
        }
    }
}
