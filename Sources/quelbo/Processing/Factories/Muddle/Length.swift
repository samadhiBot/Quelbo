//
//  Length.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LENGTH](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.zu0gcz)
    /// function.
    class Length: MuddleFactory {
        override class var zilNames: [String] {
            ["LENGTH"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .one(.unknown)
        }

        override class var returnType: Symbol.DataType {
            .int
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0).code).count",
                type: .int,
                children: symbols
            )
        }
    }
}
