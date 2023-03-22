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

        override func processTokens() throws {
            var tokens = tokens

            let globalName = try findName(in: &tokens).lowerCamelCase

            let values = try symbolize(tokens)
            guard values.nonCommentSymbols.count == 1 else {
                throw Error.expectedSingleValueSymbol(values)
            }

            symbols.append(.statement(
                id: globalName,
                code: { _ in globalName },
                type: .unknown,
                isCommittable: true,
                returnHandling: .forced
            ))
            symbols.append(contentsOf: values)
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2)),
                .haveCommonType
            )

            try symbols[1].assert(
                .hasReturnValue
            )

            try symbols[0].assert(
                .hasCategory(.globals),
                .isMutable,
                .isVariable
            )
        }

        @discardableResult
        override func process() throws -> Symbol {
            let variable = symbols[0]
            let value = symbols[1]

            return .statement(
                id: variable.code,
                code: { statement in
                    let type = statement.type
                    var assignment: String {
                        if type.isOptional == true, statement.isMutable == true {
                            return ": \(statement.typeDescription)"
                        }
                        if type.confidence < .assured, statement.isMutable == true {
                            return statement.type.emptyValueAssignment
                        }
                        return " = \(value.code)"
                    }
                    let declare = statement.isMutable != false ? "var" : "let"

                    return "\(declare) \(variable.handle)\(assignment)"
                },
                type: value.type,
                payload: .init(
                    evaluation: value.evaluation,
                    symbols: symbols
                ),
                category: variable.category,
                isCommittable: true,
                isMutable: variable.isMutable
            )
        }
    }
}

// MARK: - Errors

extension Factories.Global {
    enum Error: Swift.Error {
        case expectedSingleValueSymbol([Symbol])
    }
}
