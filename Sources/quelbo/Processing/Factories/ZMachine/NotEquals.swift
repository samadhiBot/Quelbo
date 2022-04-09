//
//  NotEquals.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import Foundation
import SwiftUI

extension Factories {
    /// A symbol factory for the Zil
    /// [N==?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3yqobt7)
    /// function.
    ///
    /// `NotEquals` is a simple negation of ``Equal``.
    class NotEquals: Equals {
        override class var zilNames: [String] {
            ["N=?", "N==?"]
        }

        override var function: String {
            "notEquals"
        }
    }
}
