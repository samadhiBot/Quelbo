//
//  Global.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GLOBAL](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2nusc19)
    /// function.
    class Global: ZilFactory {
        override class var zilNames: [String] {
            ["GLOBAL"]
        }

        override class var parameters: Parameters {
            .two(.property, .unknown)
        }

        var declare: String {
            isMutable ? "var" : "let"
        }

        override func process() throws -> Symbol {
            let nameSymbol = try symbol(0)
            let valueSymbol = try symbol(1)

            let symbol = Symbol(
                id: nameSymbol.code,
                code: "\(declare) \(nameSymbol): \(valueSymbol.type) = \(valueSymbol)",
                type: valueSymbol.type,
                category: isMutable ? .globals : .constants,
                children: valueSymbol.children
            )
            try Game.commit(symbol)
            return symbol
        }
    }
}
