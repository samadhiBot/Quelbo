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
    class Apply: MuddleFactory {
        override class var zilNames: [String] {
            ["APPLY"]
        }

        override class var parameters: SymbolFactory.Parameters {
            .oneOrMore(.unknown)
        }

        /// The user-defined applicable that is being called.
        var applicable = Symbol("TBD")

        /// The user-defined applicable parameters.
        var params: [Symbol] = []

        override func processTokens() throws {
            var tokens = tokens
            let applicableName = try findNameSymbol(in: &tokens).code

            var symbols = try symbolize(tokens)
            self.applicable = try Game.find(
                .init(stringLiteral: applicableName),
                category: .routines
            )

            self.params = try applicable.children.map { (symbol: Symbol) -> Symbol in
                guard let value = symbols.shift() else {
                    throw FactoryError.missingParameter(symbol)
                }
                return symbol.with(code: "\(symbol.id): \(value)")
            }
        }

        override func process() throws -> Symbol {
            Symbol(
                id: applicable.id,
                code: "\(applicable.id)(\(params.codeValues(.commaSeparatedNoTrailingComma)))",
                type: applicable.type,
                children: params
            )
        }
    }
}
