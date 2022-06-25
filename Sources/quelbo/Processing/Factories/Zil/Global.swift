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
    class Global: ZilFactory {
        override class var zilNames: [String] {
            ["GLOBAL", "SETG"]
        }

        override class var parameters: Parameters {
            .two(.variable(.unknown), .unknown)
        }

        var nameSymbol = Symbol(code: "TBD")
        var valueSymbol = Symbol(code: "TBD")

        override func processTokens() throws {
            try super.processTokens()

            self.nameSymbol = try symbol(0)
            self.valueSymbol = try symbol(1)
        }

        var codeBlock: (Symbol) throws -> String {
            let code = valueSymbol.code
            let type = valueSymbol.dataType

            return { symbol in
                let declare = symbol.meta.contains(.isImmutable) ? "let" : "var"
                return "\(declare) \(symbol.id): \(type) = \(code)"
            }
        }

        var metaData: Set<Symbol.MetaData> {
            []
        }

        override func process() throws -> Symbol {
            let symbol = Symbol(
                id: nameSymbol.id,
                code: codeBlock,
                type: valueSymbol.type,
                category: metaData.contains(.isImmutable) ? .constants : .globals,
                children: [valueSymbol],
                meta: metaData.union(valueSymbol.meta).subtracting([.isLiteral])
            )

            Game.commit(symbol)
            return symbol
        }
    }
}


// MARK: - Errors

extension Factories.Global {
    enum Error: Swift.Error {
        case unconsumedGlobalTokens([Token])
    }
}
