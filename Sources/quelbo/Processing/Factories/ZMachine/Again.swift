//
//  Again.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/24/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [AGAIN](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1au1eum)
    /// function.
    class Again: ZMachineFactory {
        override class var zilNames: [String] {
            ["AGAIN"]
        }

        override class var parameters: Parameters {
            .zeroOrOne(.unknown)
        }

        override func process() throws -> Symbol {
            if let activation = symbols.first?.code {
                return Symbol("continue \(activation)", children: symbols)
            } else {
                return Symbol("continue", children: symbols)
            }
        }
    }
}
