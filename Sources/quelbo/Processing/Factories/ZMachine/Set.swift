//
//  Set.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/4/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [SET](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.27jua8u) and
    /// [SETG](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.mp4kgn)
    /// functions.
    class Set: ZMachineFactory {
        override class var zilNames: [String] {
            ["SET", "SETG"]
        }

        override class var parameters: Parameters {
            .two(.property, .unknown)
        }

        override class var returnType: Symbol.DataType {
            .unknown
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0)).set(to: \(try symbol(1)))",
                type: try symbol(1).type,
                children: symbols
            )
        }
    }
}
