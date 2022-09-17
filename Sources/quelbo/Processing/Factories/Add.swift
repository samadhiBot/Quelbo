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
    class Add: Factory {
        override class var zilNames: [String] {
            ["+", "ADD"]
        }

        var function: String {
            "add"
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.atLeast(2)),
                .haveType(.int)
            ])

            try? symbols[0].assert(.isMutable)
        }

        override func process() throws -> Symbol {
            let originals = symbols
            let function = function

            return .statement(
                code: { _ in
                    var arguments = originals

                    guard
                        let first = arguments.shift(),
                        case .variable(let variable) = first,
                        variable.isMutable ?? false
                    else {
                        return ".\(function)(\(originals.codeValues(.commaSeparated)))"

                    }
                    return "\(first.code).\(function)(\(arguments.codeValues(.commaSeparated)))"
                },
                type: .int
            )
        }
    }
}
