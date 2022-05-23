//
//  ChangeType.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [CHTYPE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2grqrue)
    /// function.
    class ChangeType: MuddleFactory {
        override class var zilNames: [String] {
            ["CHTYPE"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .two(.unknown, .unknown)
        }

        override func process() throws -> Symbol {
            let value = try symbol(0)
            let newType = try symbol(1)

            return Symbol(
                "\(value).changeType(\(newType))",
                children: symbols
            )
        }
    }
}
