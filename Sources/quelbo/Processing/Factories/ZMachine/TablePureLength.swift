//
//  TablePureLength.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/2/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PLTABLE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.yoal25lo9g0s)
    /// function.
    class TablePureLength: Table {
        override class var zilNames: [String] {
            ["PLTABLE"]
        }

        override var isLengthTable: Bool {
            true
        }

        override var isPureTable: Bool {
            true
        }
    }
}
