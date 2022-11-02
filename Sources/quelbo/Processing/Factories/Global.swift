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
        override class var factoryType: FactoryType {
            .mdl
        }

        override class var zilNames: [String] {
            ["GLOBAL", "SETG"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.exactly(2)),
                .haveCommonType
            ])

            try symbols[1].assert(
                .hasReturnValue
            )

            let mutable = symbols[1].isMutable != false

            try symbols[0].assert([
                .hasCategory(mutable ? .globals : .constants),
                .isVariable,
                mutable ? .isMutable : .isImmutable,
            ])
        }

        @discardableResult
        override func process() throws -> Symbol {
            let variable = symbols[0]
            let value = symbols[1]

            return .statement(
                id: variable.code,
                code: { statement in
                    let type = statement.type
                    let assignment = {
                        if type.isOptional == true { return statement.typeDescription }
                        if type.confidence < .assured { return statement.type.emptyValueAssignment }
                        return "\(statement.typeDescription) = \(value.code)"
                    }()
                    let declare = variable.isMutable != false ? "var" : "let"

                    return "\(declare) \(variable.handle): \(assignment)"
                },
                type: value.type,
                payload: .init(
                    symbols: [variable, value]
                ),
                category: variable.isMutable ?? false ? .globals : .constants,
                isCommittable: true
            )
        }
    }
}

// MARK: - Errors

extension Factories.Global {
    enum Error: Swift.Error {
        case unconsumedGlobalTokens([Token])
    }
}
