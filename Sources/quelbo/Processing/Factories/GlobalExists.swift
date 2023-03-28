//
//  GlobalExists.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/7/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GASSIGNED?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1baon6m)
    /// function.
    class GlobalExists: Factory {
        override class var zilNames: [String] {
            ["GASSIGNED?"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1))
            )
        }

        override func processOrEvaluate() throws -> Symbol {
            guard
                let globalID = symbols.first?.id,
                try Game.find(globalID) != nil
            else {
                return .false
            }
            return .true
        }
    }
}
