//
//  IsNotEqualTo.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [N=?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3yqobt7)
    /// function.
    class IsNotEqualTo: Equals {
        override class var zilNames: [String] {
            ["N=?", "N==?"]
        }

        override var function: String {
            "isNotEqualTo"
        }

        override func evaluate() throws -> Symbol {
            guard let firstElement = symbols.first?.evaluation else {
                return .false
            }
            for element in symbols.nonCommentSymbols[1..<symbols.count].compactMap(\.evaluation) {
                guard element != firstElement else { return .false }
            }
            return .true
        }
    }
}
