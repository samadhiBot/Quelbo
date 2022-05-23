//
//  Table.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [TABLE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2kz067v)
    /// function.
    class Table: ZMachineFactory {
        override class var zilNames: [String] {
            ["TABLE", "LTABLE"]
        }

        override class var parameters: Parameters {
            .twoOrMore(.zilElement)
        }

        override class var returnType: Symbol.DataType {
            .array(.zilElement)
        }

        override func process() throws -> Symbol {
            Symbol(
                "[\(symbols.codeValues(.commaSeparated, .indented))]",
                type: .array(.zilElement),
                children: symbols
            )
        }
    }
}
