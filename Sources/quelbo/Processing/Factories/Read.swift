//
//  Read.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [READ](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3na04zk)
    /// function.
    class Read: Factory {
        override class var zilNames: [String] {
            ["READ"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.exactly(2)),
                .haveType(.table),
            ])
        }

        override func process() throws -> Symbol {
            let tables = symbols
                .map { "&\($0.code)" }
                .values(.commaSeparated)

            return .statement(
                code: { _ in
                    "read(\(tables))"
                },
                type: .void,
                confidence: .certain
            )
        }
    }
}
