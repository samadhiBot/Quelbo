//
//  Parent.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LOC](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.19mgy3x)
    /// function.
    class Parent: Factory {
        override class var zilNames: [String] {
            ["LOC"]
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
                    "\(object.code).parent"
                },
                type: .object
            )
        }
    }
}
