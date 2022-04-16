//
//  ProgramBlock.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PROG](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1bkyn9b)
    /// function.
    class ProgramBlock: ZMachineFactory {
        override class var zilNames: [String] {
            ["PROG"]
        }

        override class var parameters: Parameters {
            .twoOrMore(.unknown)
        }

        override class var returnType: Symbol.DataType {
            .unknown
        }

        var function: String {
            "prog"
        }

        override func process() throws -> Symbol {
            Symbol(
                """
                \(function) {
                \(symbols.codeValues(lineBreaks: 1).indented)
                }
                """,
                type: .unknown,
                children: symbols
            )
        }
    }
}
