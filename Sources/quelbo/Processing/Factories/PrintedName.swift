//
//  PrintedName.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PNAME](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3dhjn8m) and
    /// [SPNAME](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3fg1ce0)
    /// functions.
    class PrintedName: Factory {
        override class var zilNames: [String] {
            ["PNAME", "SPNAME"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1)),
                .areVariables
            )
        }

        override func process() throws -> Symbol {
            let variable = symbols[0]

            return .statement(
                code: { _ in
                    "\(variable.code).id"
                },
                type: .string
            )
        }
    }
}
