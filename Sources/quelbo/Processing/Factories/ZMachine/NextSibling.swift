//
//  NextSibling.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [NEXT?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2dvym10)
    /// function.
    class NextSibling: ZMachineFactory {
        override class var zilNames: [String] {
            ["NEXT?"]
        }

        override class var parameters: Parameters {
            .one(.object)
        }

        override func process() throws -> Symbol {
            let object = try symbol(0)
            return Symbol(
                "\(object).nextSibling",
                type: .object,
                children: symbols
            )
        }
    }
}
