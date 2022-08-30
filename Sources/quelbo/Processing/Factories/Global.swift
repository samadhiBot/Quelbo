//
//  Global.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GLOBAL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2nusc19) and
    /// [SETG](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.415t9al)
    /// (when called at root level) functions.
    class Global: Factory {
        override class var zilNames: [String] {
            ["GLOBAL", "SETG"]
        }

        override class var muddle: Bool {
            true
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCommonType,
                .haveCount(.exactly(2)),
            ])

            try symbols[1].assert(
                .hasReturnValue
            )

            let mutable = symbols[1].isMutable != false

            try symbols[0].assert([
                .hasCategory(mutable ? .globals : .constants),
                .isVariable,
                mutable ? .isMutable : .isImmutable
            ])
        }

        @discardableResult
        override func process() throws -> Symbol {
            let variable = symbols[0]
            let value = symbols[1]

            let assignment = Statement(
                id: variable.code,
                code: { _ in
                    let declare = variable.isMutable != false ? "var" : "let"
                    var assignment: String {
                        if value.confidence ?? .unknown < .assured, let type = variable.type {
                            return type.emptyValueAssignment
                        } else {
                            return " = \(value.code)"
                        }
                    }

                    return "\(declare) \(variable.code): \(variable.type ?? .unknown)\(assignment)"
                },
                type: variable.type,
                confidence: variable.confidence,
                category: variable.isMutable ?? false ? .globals : .constants
            )

            try Game.commit([
                variable,
                .statement(assignment)
            ])

            return .statement(assignment)
        }
    }
}

// MARK: - Errors

extension Factories.Global {
    enum Error: Swift.Error {
        case unconsumedGlobalTokens([Token])
    }
}
