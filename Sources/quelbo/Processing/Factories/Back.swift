//
//  Back.swift
//  Quelbo
//
//  Created by Chris Sessions on 12/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [BACK](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1o97atn)
    /// function.
    class Back: Factory {
        override class var zilNames: [String] {
            ["BACK"]
        }

        var method: String {
            "back"
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.between(1...2))
            )

            if symbols[0].type != .table {
                try symbols[0].assert(.isArray)
            }

            if symbols.count == 2 {
                try symbols[1].assert(
                    .hasType(.int)
                )
            }
        }

        override func process() throws -> Symbol {
            let structure = symbols[0]
            let bytes = symbols.count == 2 ? symbols[1].handle : "1"
            let method = method

            return .statement(
                code: { _ in
                    "\(structure.handle).\(method)(bytes: \(bytes))"
                },
                type: structure.type
            )
        }
    }
}
