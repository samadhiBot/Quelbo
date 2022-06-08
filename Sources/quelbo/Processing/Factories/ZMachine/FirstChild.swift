//
//  FirstChild.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [FIRST?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3jd0qos)
    /// function.
    class FirstChild: ZMachineFactory {
        override class var zilNames: [String] {
            ["FIRST?"]
        }

        override class var parameters: Parameters {
            .one(.object)
        }

        override func process() throws -> Symbol {
            let object = try symbol(0)
            return Symbol(
                "\(object).firstChild",
                type: .object,
                children: symbols
            )
        }
    }
}
