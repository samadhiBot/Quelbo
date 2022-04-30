//
//  Version.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/20/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [VERSION](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3c9z6hx)
    /// function.
    class Version: Constant {
        override class var zilNames: [String] {
            ["VERSION"]
        }

        override func processTokens() throws {
            let zMachineVersion = try Game.ZMachineVersion(tokens: tokens)
            symbols.append(Symbol(
                "zMachineVersion",
                type: .string
            ))
            symbols.append(Symbol(
                zMachineVersion.rawValue.quoted,
                type: .string,
                literal: true
            ))
        }
    }
}
