//
//  IsVersion.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/30/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [VERSION?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1rf9gpq)
    /// function.
    class IsVersion: ZilFactory {
        override class var zilNames: [String] {
            ["VERSION?"]
        }

        func conditionalSymbols() throws -> [Symbol] {
            var conditions: [Symbol] = []
            var symbols = symbols
            while let list = symbols.shift() {
                var condition = list.children
                guard
                    list.type == .list,
                    let predicate = condition.shift()
                else {
                    throw FactoryError.invalidValue(list)
                }

                let ifStatement: String
                switch predicate.id {
                    case "else", "t", "true":
                        ifStatement = ""
                    default:
                        ifStatement = "if zMachineVersion == \(predicate) "
                }

                conditions.append(Symbol(
                    """
                    \(ifStatement){
                    \(condition.codeValues(.singleLineBreak, .indented))
                    }
                    """,
                    children: list.children
                ))
            }
            return conditions
        }

        override func process() throws -> Symbol {
            let symbol = Symbol(
                try conditionalSymbols().codeValues(.separator(" else ")),
                type: .void,
                children: symbols
            )
            try Game.commit(symbol)
            return symbol
        }
    }
}
