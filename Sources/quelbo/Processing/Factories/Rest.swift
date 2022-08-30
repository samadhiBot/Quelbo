//
//  Rest.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [REST](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.49gfa85)
    /// function.
    class Rest: Factory {
        override class var zilNames: [String] {
            ["REST"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.between(1...2)))

            if symbols.count == 1 {
                symbols.append(.statement(
                    code: { _ in "" },
                    type: .int,
                    confidence: .certain
                ))
            }

            try? symbols[0].assert(.hasType(.array(.unknown)))
            try symbols[1].assert(.hasType(.int))
        }

        override func process() throws -> Symbol {
            let structure = symbols[0]
            let count = symbols[1]

            return .statement(
                code: { _ in
                    "\(structure.code).rest(\(count.code))"
                },
                type: structure.type,
                confidence: structure.confidence
            )
        }
    }
}
