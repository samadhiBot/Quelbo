//
//  Cond.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [COND](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.u8tczi)
    /// function.
    class Cond: ZMachineFactory {
        override class var zilNames: [String] {
            ["COND"]
        }

        override var parameters: Parameters {
            .oneOrMore(.list)
        }

        func conditionalSymbols() throws -> [Symbol] {
            var conditions: [Symbol] = []
            var symbols = symbols
            while !symbols.isEmpty {
                let list = symbols.removeFirst()
                var condition = list.children
                guard
                    list.type == .list,
                    let predicate = condition.shift(),
                    !condition.isEmpty
                else {
                    throw FactoryError.invalidValue(list)
                }
                let ifStatement = "if " //conditions.isEmpty || !symbols.isEmpty ? "if " : ""
//                print("// 🍐 '\(ifStatement)' conditions.isEmpty: \(conditions.isEmpty), !symbols.isEmpty: \(!symbols.isEmpty)")
                conditions.append(Symbol(
                    """
                    \(ifStatement)\(predicate) {
                    \(condition.codeValues(lineBreaks: 1).indented())
                    }
                    """,
                    type: (try? condition.commonType()) ?? .void,
                    children: list.children
                ))
            }
            return conditions
        }

        override func process() throws -> Symbol {
            Symbol(
                try conditionalSymbols().codeValues(separator: " else "),
                type: (try? symbols.commonType()) ?? .void,
                children: symbols
            )
        }
    }
}
