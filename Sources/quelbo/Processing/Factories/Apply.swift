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

        /// The user-defined applicable that is being called.
        var applicable: Statement!

        /// The user-defined applicable parameters.
        var params: [Symbol] = []

        override func processTokens() throws {
            var tokens = tokens

            let name = try findName(in: &tokens)
            var symbols = try symbolize(tokens)

            guard let applicable = Game.routines.find(name) else {
                throw Error.missingApplyRoutine(name)
            }
            self.applicable = applicable

            self.params = try applicable.parameters.map { (instance: Instance) -> Symbol in
                guard let value = symbols.shift() else {
                    throw Error.missingApplyParameter(instance)
                }

                return .statement(
                    code: { _ in
                        "\(instance.code): \(value.code)"
                    },
                    type: value.type
                )
            }
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.atLeast(1)))
        }

        override func process() throws -> Symbol {
            let applicable = applicable!
            let params = params

            return .statement(
                code: { _ in
                    "\(applicable)(\(params.codeValues(.commaSeparatedNoTrailingComma)))"
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
