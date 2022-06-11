//
//  PutRest.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PUTREST](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4hr1b5p)
    /// functions.
    class PutRest: MuddleFactory {
        override class var zilNames: [String] {
            ["PUTREST"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .two(.array(.unknown), .array(.unknown))
        }

        override func process() throws -> Symbol {
            let arrayOne = try symbol(0)
            let arrayTwo = try symbol(1)

            return Symbol(
                "\(arrayOne.code).putRest(\(arrayTwo.code))",
                type: arrayOne.type,
                children: symbols
            )
        }
    }
}
