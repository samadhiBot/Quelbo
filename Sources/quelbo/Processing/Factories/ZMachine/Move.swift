//
//  Move.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [MOVE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1er0t5e)
    /// function.
    class Move: ZMachineFactory {
        override class var zilNames: [String] {
            ["MOVE"]
        }

        override var parameters: Parameters {
            .two(.object, .object)
        }

        override var returnType: Symbol.DataType {
            .void
        }

        override func process() throws -> Symbol {
            Symbol(
                "\(try symbol(0)).move(to: \(try symbol(1)))",
                type: .void,
                children: symbols
            )
        }
    }
}
