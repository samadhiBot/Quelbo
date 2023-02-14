//
//  ProgramBlockMDL.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/7/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the MDL
    /// [PROG](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.356xmb2)
    /// function.
    class ProgramBlockMDL: ProgramBlock {
        override class var factoryType: Factories.FactoryType {
            .mdl
        }

        override func process() throws -> Symbol {
            .statement(
                code: { _ in "%prog" },
                type: .unknown,
                payload: blockProcessor.payload
            )
        }
    }
}
