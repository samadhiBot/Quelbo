//
//  ContainerFunction.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/1/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `CONTFCN` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class ContainerFunction: Factory {
        override class var factoryType: FactoryType {
            .property
        }

        override class var zilNames: [String] {
            ["CONTFCN"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.between(0...1)),
                .haveType(.routine),
            ])
        }

        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "containerFunction" },
                    type: .routine
                )
            }
            let function = symbols[0]

            return .statement(
                id: "containerFunction",
                code: { _ in
                    "containerFunction: \(function.code)"
                },
                type: .routine
            )
        }
    }
}
