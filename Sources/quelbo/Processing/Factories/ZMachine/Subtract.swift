//
//  Subtract.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [SUB](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.xevivl)
    /// function.
    class Subtract: Add {
        override class var zilNames: [String] {
            ["-", "SUB"]
        }

        override class var parameters: Parameters {
            .oneOrMore(.int)
        }

        override var function: String {
            "subtract"
        }

        override func process() throws -> Symbol {
            guard symbols.count == 1 else {
                return try super.process()
            }

            return Symbol(
                "-\(try symbol(0).code)",
                type: .int,
                children: symbols
            )
        }
    }
}
