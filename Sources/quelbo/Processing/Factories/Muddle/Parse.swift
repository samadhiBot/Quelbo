//
//  Parse.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PARSE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2eclud0)
    /// functions.
    class Parse: MuddleFactory {
        override class var zilNames: [String] {
            ["PARSE"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .oneOrMore(.unknown)
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
