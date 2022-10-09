//
//  Apply.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/14/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [APPLY](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2xcytpi)
    /// function.
    class Apply: Factory {
        override class var zilNames: [String] {
            ["APPLY"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(1))
            )
        }

        override func process() throws -> Symbol {
            let applicable = symbols.removeFirst()
            let params = symbols

            return .statement(
                code: { _ in
                    "\(applicable.handle)(\(params.handles(.commaSeparatedNoTrailingComma)))"
                },
                type: applicable.type
            )
        }
    }
}

// MARK: - Errors

extension Factories.Apply {
    enum Error: Swift.Error {
        case missingApplyRoutine(String)
        case missingApplyParameter(Instance)
    }
}
