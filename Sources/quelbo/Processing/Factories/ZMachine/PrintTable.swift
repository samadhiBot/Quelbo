//
//  PrintTable.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PRINTF](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2j0ih2h)
    /// function.
    class PrintTable: Print {
        override class var zilNames: [String] {
            ["PRINTF"]
        }

        override var parameters: Parameters {
            .one(.array(.tableElement))
        }

        func tableContents() throws -> String {
            try symbol(0).children
                .map { "\\(\($0))" }
                .joined(separator: "\n")
                .indented()
        }

        override func process() throws -> Symbol {
            Symbol(
                """
                    output(\"""
                    \(try tableContents())
                    \""")
                    """,
                type: .void,
                children: symbols
            )
        }
    }
}
