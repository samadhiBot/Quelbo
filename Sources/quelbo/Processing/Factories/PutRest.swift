//
//  PutRest.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PUTREST](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4hr1b5p)
    /// functions.
    class PutRest: Factory {
        override class var zilNames: [String] {
            ["PUTREST"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(2)))

            try? symbols[0].assert(.hasType(.array(.unknown)))
            try? symbols[1].assert(.hasType(.array(.unknown)))
        }

        override func process() throws -> Symbol {
            let arrayOne = symbols[0]
            let arrayTwo = symbols[1]
            let type = arrayOne.type == arrayTwo.type ? arrayOne.type : .array(.zilElement)
            let confidence = min(arrayOne.confidence ?? .unknown, arrayOne.confidence ?? .unknown)

            return .statement(
                code: { _ in
                    "\(arrayOne.code).putRest(\(arrayTwo.code))"
                },
                type: type,
                confidence: confidence
            )
        }
    }
}
