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

//        override class var parameters: Parameters {
//            .oneOrMore(.list)
//        }


        func conditionalSymbols() throws -> [Symbol] {
            var conditions: [Symbol] = []
            var symbols = symbols
            while let list = symbols.shift() {
                var condition = list.children
                guard
                    list.type == .list,
                    let predicate = condition.shift(),
                    !condition.isEmpty
                else {
                    throw FactoryError.invalidValue(list)
                }

                let ifStatement: String
                switch predicate.id {
                    case "else", "t", "true":
                        ifStatement = ""
                    default:
                        ifStatement = "if \(predicate) "
                }

                conditions.append(Symbol(
                    """
                    \(ifStatement){
                    \(condition.codeValues(lineBreaks: 1).indented)
                    }
                    """,
//                    type: (try? condition.commonType()) ?? .void,
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
