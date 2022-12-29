//
//  Capacity.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `CAPACITY` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Capacity: Factory {
        override class var factoryType: FactoryType {
            .property
        }

        override class var zilNames: [String] {
            ["CAPACITY"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.between(0...1)),
                .haveType(.int)
            )
        }

        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "capacity" },
                    type: .int
                )
            }

            let capacity = symbols[0]

            return .statement(
                id: "capacity",
                code: { _ in
                    "capacity: \(capacity.code)"
                },
                type: .int
            )
        }
    }
}
