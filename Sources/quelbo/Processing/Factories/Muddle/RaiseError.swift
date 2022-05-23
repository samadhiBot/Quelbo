//
//  RaiseError.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ERROR](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.zu0gcz)
    /// function.
    class RaiseError: MuddleFactory {
        override class var zilNames: [String] {
            ["ERROR"]
        }

        override func process() throws -> Symbol {
            Symbol(
                id: "<Error>",
                code: "throw FizmoError.mdlError(\(symbols.codeValues(.commaSeparated))",
                children: symbols
            )
        }
    }
}
