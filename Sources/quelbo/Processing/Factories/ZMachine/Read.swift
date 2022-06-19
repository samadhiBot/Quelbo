//
//  Read.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [READ](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.pv6qcq)
    /// function.
    class Read: ZMachineFactory {
        override class var zilNames: [String] {
            ["READ"]
        }

        override class var parameters: Parameters {
            .two(.table, .table)
        }

        override func process() throws -> Symbol {
            Symbol(
                "read(\(symbols.codeValues()))",
                type: .void,
                children: symbols
            )
        }
    }
}
