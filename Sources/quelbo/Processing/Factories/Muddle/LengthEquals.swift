//
//  LengthEquals.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LENGTH?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.zu0gcz)
    /// function.
    class LengthEquals: MuddleFactory {
        override class var zilNames: [String] {
            ["LENGTH?"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .two(.array(.unknown), .int)
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        override func process() throws -> Symbol {
            let container = try symbol(0)
            let length = try symbol(1)

            return Symbol(
                "\(container.code).count == \(length.code)",
                type: .bool,
                children: symbols
            )
        }
    }
}
