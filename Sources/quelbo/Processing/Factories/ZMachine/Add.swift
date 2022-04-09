//
//  Add.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ADD](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2i9l8ns)
    /// function.
    class Add: ZMachineFactory {
        override class var zilNames: [String] {
            ["+", "ADD"]
        }

        override var parameters: Parameters {
            .twoOrMore(.int)
        }

        override var returnType: Symbol.DataType {
            .int
        }

        var function: String {
            "add"
        }

        override func process() throws -> Symbol {
            let original = symbols
            guard let first = symbols.shift() else {
                throw FactoryError.missingValue(tokens)
            }

            return Symbol(
                "\(first).\(function)(\(symbols.codeValues(separator: ",")))",
                type: .int,
                children: original
            )
        }
    }
}
