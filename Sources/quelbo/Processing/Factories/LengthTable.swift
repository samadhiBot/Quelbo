//
//  LengthTable.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/2/22.
//

import Fizmo
import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LTABLE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.rjefff)
    /// function.
    class LengthTable: Table {
        override class var zilNames: [String] {
            ["LTABLE"]
        }

        override var presetFlags: [Fizmo.Table.Flag] {
            [.length]
        }

        override func processSymbols() throws {
            if flags == presetFlags, case .decimal(0) = tokens.first {
                symbols.removeFirst()
            }

            try super.processSymbols()
        }
    }
}
