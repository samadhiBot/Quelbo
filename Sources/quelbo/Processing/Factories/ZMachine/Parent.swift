//
//  Parent.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LOC](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.19mgy3x)
    /// function.
    class Parent: ZMachineFactory {
        override class var zilNames: [String] {
            ["LOC"]
        }

        override class var parameters: Parameters {
            .one(.object)
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0).code).parent",
                type: .object,
                children: symbols
            )
        }
    }
}
