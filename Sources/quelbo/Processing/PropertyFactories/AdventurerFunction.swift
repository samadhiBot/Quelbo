//
//  AdventurerFunction.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/13/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the `ADVFCN` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class AdventurerFunction: Factory {
        override class var factoryType: FactoryType {
            .property
        }

        override class var zilNames: [String] {
            ["ADVFCN"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.between(0...1)),
                .haveType(.routine.property)
            )
        }

        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "adventurerFunction" },
                    type: .routine
                )
            }
            let function = symbols[0]

            return .statement(
                id: "adventurerFunction",
                code: { _ in
                    "adventurerFunction: \(function.code)"
                },
                type: .routine
            )
        }
    }
}
