//
//  SetVariable.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/4/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [SET](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.27jua8u) and
    /// [SETG](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.mp4kgn)
    /// (when called at routine level) functions.
    class SetVariable: ZMachineFactory {
        override class var zilNames: [String] {
            ["SET", "SETG"]
        }

        override class var parameters: Parameters {
            .two(.variable(.unknown), .unknown)
        }

        override func process() throws -> Symbol {
            let variable = try symbol(0).with(meta: [.mutating(true)])
            let value = try symbol(1)

            return Symbol(
                "\(variable.code).set(to: \(value.code))",
                type: value.type,
                children: [variable, value]
            )
        }
    }
}
