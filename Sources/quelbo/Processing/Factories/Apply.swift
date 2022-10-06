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

//        /// The user-defined applicable that is being called.
//        var applicable: Statement!
//
//        /// The user-defined applicable parameters.
//        var params: [Symbol] = []

//        override func processTokens() throws {
//            var tokens = tokens.
//
//            guard
//                let applicableToken = tokens.shift()
//            else {
//                throw Error.missingApplyRoutine("asdf")
//            }
//            let applicableSymbol = try symbolize(applicableToken)
//
////            let zilName = try findName(in: &tokens)
//            var symbols = try symbolize(tokens)
//
//            if let applicable = Game.routines.find("zilName") {
//                self.applicable = applicable
//            } else {
//                let routine = try Factories.Routine(
//                    self.tokens,
//                    with: &localVariables
//                ).process()
//                guard case .statement(let routineStatement) = routine else {
//                    throw Error.missingApplyRoutine("zilName")
//                }
//                self.applicable = routineStatement
//            }
//
//            self.params = try applicable.parameters.map { (instance: Instance) -> Symbol in
//                guard let value = symbols.shift() else {
//                    throw Error.missingApplyParameter(instance)
//                }
//
//                return .statement(
//                    code: { _ in
//                        "\(instance.code): \(value.code)"
//                    },
//                    type: value.type
//                )
//            }
//        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(1))
            )
//            try symbols.assert(.haveCount(.atLeast(1)))
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
