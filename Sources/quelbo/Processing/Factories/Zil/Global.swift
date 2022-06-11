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
    /// functions.
    class Global: ZilFactory {
        override class var zilNames: [String] {
            ["GLOBAL", "SETG"]
        }

        override class var parameters: Parameters {
            .two(.variable(.unknown), .unknown)
        }

        var metaData: [Symbol.MetaData] = []
        var nameSymbol = Symbol("TBD")
        var valueSymbol = Symbol("TBD")

        override func processTokens() throws {
            try super.processTokens()

            self.nameSymbol = try symbol(0)
            self.valueSymbol = try symbol(1)

            for metaData in valueSymbol.meta {
                switch metaData {
                case .maybeEmptyValue: self.metaData = [.maybeEmptyValue]
                case .mutating(true): self.isMutable = true
                case .mutating(false): self.isMutable = false
                default: break
                }
            }
        }

        var codeBlock: String {
            let declare = isMutable ? "var" : "let"

            return "\(declare) \(nameSymbol.code): \(valueSymbol.dataType) = \(valueSymbol.code)"
        }

        override func process() throws -> Symbol {
            let symbol = Symbol(
                id: .init(stringLiteral: nameSymbol.code),
                code: codeBlock,
                type: valueSymbol.type,
                category: isMutable ? .globals : .constants,
                children: [valueSymbol],
                meta: metaData
            )
            try Game.commit(symbol)
            return symbol
        }
    }
}
