//
//  PrintedName.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PNAME](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2lfnejv) and
    /// [SPNAME](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3fg1ce0)
    /// functions.
    class PrintedName: MuddleFactory {
        override class var zilNames: [String] {
            ["PNAME", "SPNAME"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .one(.unknown)
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0).code).printedName",
                type: .string,
                children: symbols
            )
        }
    }
}
