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

        var zilName: String?

        override func processTokens() throws {
            var tokens = tokens

            let zilName = try findName(in: &tokens)
            let globalName = zilName.lowerCamelCase
            self.zilName = zilName

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
                .hasReturnValue,
                .isTableRoot
            )

            try symbols[0].assert(
                .hasCategory(.globals),
                .isMutable,
                .isVariable
            )
        }

        @discardableResult
        override func process() throws -> Symbol {
            let zilName = zilName

            return .statement(
                id: symbols[0].code,
                code: { statement in
                    let type = statement.type
                    var assignment: String {
                        if type.isOptional == true, statement.isMutable == true {
                            return ": \(statement.typeDescription)"
                        }
                        if type.confidence < .assured, statement.isMutable == true {
                            return statement.type.emptyValueAssignment
                        }
                        return " = \(statement.payload.symbols[1].code)"
                    }
                    var comment: String {
                        guard let zilName else {
                            return ""
                        }
                        return """
                            /// The `\(variable)` (\(zilName)) \(type.debugDescription) \
                            \(statement.payload.symbols[0].category?.name ?? "variable").\n
                            """
                    }
                    let declare = statement.isMutable != false ? "var" : "let"
                    let variable = statement.payload.symbols[0].handle

                    return "\(comment)\(declare) \(variable)\(assignment)"
                },
                type: symbols[1].type,
                payload: .init(
                    evaluation: symbols[1].evaluation,
                    symbols: symbols
                ),
                category: symbols[0].category,
                isCommittable: true,
                isMutable: symbols[0].isMutable
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
