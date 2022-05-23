//
//  Equals.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import Foundation
import SwiftUI

extension Factories {
    /// A symbol factory for the Zil
    /// [EQUAL?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2vor4mt)
    /// function.
    class Equals: ZMachineFactory {
        override class var zilNames: [String] {
            ["=?", "==?", "EQUAL?"]
        }

        override class var parameters: Parameters {
            .twoOrMore(.unknown)
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        var function: String {
            "equals"
        }

        override func process() throws -> Symbol {
            let original = symbols
            guard let first = symbols.shift() else {
                throw FactoryError.missingValue(tokens)
            }

            return Symbol(
                "\(first).\(function)(\(symbols.codeValues(.commaSeparated)))",
                type: .bool,
                children: original
            )
        }
    }
}
