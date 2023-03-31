//
//  NullFunc.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/13/22.
//

import Foundation

extension Factories {
    /// A Fizmo symbol factory for the Infocom `NULL-F` routine.
    class NullFunc: Factory {
        override class var zilNames: [String] {
            ["NULL-F"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.between(0...2)))
        }

        override func process() throws -> Symbol {
            .statement(
                id: "nullFunc",
                code: { _ in "nullFunc()" },
                type: .bool,
                isFunctionCall: true
            )
        }
    }
}
