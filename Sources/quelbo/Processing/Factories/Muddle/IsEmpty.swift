//
//  IsEmpty.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [EMPTY?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2dlolyb)
    /// function.
    class IsEmpty: MuddleFactory {
        override class var zilNames: [String] {
            ["EMPTY?"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .one(.unknown)
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0).code).isEmpty",
                type: .bool,
                children: symbols
            )
        }
    }
}
