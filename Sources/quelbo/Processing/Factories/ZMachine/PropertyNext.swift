//
//  PropertyNext.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [NEXTP](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.t18w8t)
    /// function.
    class PropertyNext: ZMachineFactory {
        override class var zilNames: [String] {
            ["NEXTP"]
        }

        override class var parameters: Parameters {
            .two(.object, .property)
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0).code).nextProperty(after: .\(try symbol(1).code))",
                type: .int,
                children: symbols
            )
        }
    }
}
