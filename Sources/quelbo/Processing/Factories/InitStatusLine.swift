//
//  InitStatusLine.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/20/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [INIT-STATUS-LINE](https://archive.org/details/Learning_ZIL_Steven_Eric_Meretzky_1995/page/n63/mode/1up)
    /// function.
    class InitStatusLine: Factory {
        override class var zilNames: [String] {
            ["INIT-STATUS-LINE"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(0))
            )
        }

        override func process() throws -> Symbol {
            .statement(
                code: { _ in
                    "initStatusLine()"
                },
                type: .void
            )
        }
    }
}
