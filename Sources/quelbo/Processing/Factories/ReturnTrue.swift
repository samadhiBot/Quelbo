//
//  ReturnTrue.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [RTRUE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4e4bwxm)
    /// function.
    class ReturnTrue: Factory {
        override class var zilNames: [String] {
            ["RTRUE"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(0)))

            symbols = [.literal(true)]
        }

        override func process() throws -> Symbol {
            let value = symbols[0]

            return .statement(
                code: { statement in
                    guard statement.type == .bool || value.code == "true" else {
                        return "return nil"
                    }

                    return "return \(value.code)"
                },
                type: .bool,
                confidence: value.confidence,
                quirk: .returnStatement,
                returnable: .explicit
            )
        }
    }
}
