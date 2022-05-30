//
//  Other.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for any unhandled properties of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Other: ZilPropertyFactory {
        var name: Symbol!

        override func processTokens() throws {
            var tokens = tokens
            self.name = try findNameSymbol(in: &tokens)
            self.symbols = try symbolize(tokens)
        }

        override func process() throws -> Symbol {
            let code: String
            switch symbols.count {
                case 0:
                    throw FactoryError.missingParameters(tokens)
                case 1:
                    code = try symbol(0).code
                default:
                    code = "[\(symbols.codeValues(.commaSeparated))]"
            }

            return Symbol(
                id: .init(stringLiteral: name.code),
                code: "\(name.code): \(code)",
                type: try symbols.commonType(),
                children: symbols
            )
        }
    }
}
