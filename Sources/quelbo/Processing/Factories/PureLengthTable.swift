//
//  PureLengthTable.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/2/22.
//

import Fizmo
import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PLTABLE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.yoal25lo9g0s)
    /// function.
    class PureLengthTable: LengthTable {
        override class var zilNames: [String] {
            ["PLTABLE"]
        }

        override var presetFlags: [Fizmo.Table.Flag] {
            [.length, .pure]
        }
    }
}
