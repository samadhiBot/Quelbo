//
//  TableLength.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/2/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LTABLE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.rjefff)
    /// function.
    class TableLength: Table {
        override class var zilNames: [String] {
            ["LTABLE"]
        }

        override var isLengthTable: Bool {
            true
        }
    }
}
