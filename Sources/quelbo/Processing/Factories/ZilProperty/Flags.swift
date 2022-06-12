//
//  Flags.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Fizmo
import Foundation

extension Factories {
    /// A symbol factory for the `FLAGS` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Flags: ZilPropertyFactory {
        override class var zilNames: [String] {
            ["FLAGS"]
        }

        override class var parameters: Parameters {
            .oneOrMore(.bool)
        }

        override class var returnType: Symbol.DataType {
            .array(.bool)
        }

        override func processTokens() throws {
            try super.processTokens()

            symbols = try symbols.map { symbol in
                if let flag = try? Game.find(symbol.id, category: .flags) {
                    return flag
                } else {
                    var flagCode = symbol.code
                    if let predefined = Flag.find(symbol.code) {
                        flagCode = predefined.id.description
                    }
                    let flag = symbol.with(code: flagCode, category: .flags)
                    try Game.commit(flag)
                    return flag
                }
            }
        }

        override func process() throws -> Symbol {
            Symbol(
                id: "flags",
                code: "flags: [\(symbols.sorted.codeValues(.commaSeparated))]",
                type: Self.returnType,
                children: symbols
            )
        }
    }
}
