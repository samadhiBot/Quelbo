//
//  Again.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/24/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [AGAIN](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1au1eum)
    /// function.
    class Again: ZMachineFactory {
        override class var zilNames: [String] {
            ["AGAIN"]
        }

        override class var parameters: Parameters {
            .zeroOrOne(.unknown)
        }

        override func process() throws -> Symbol {
            var activation: String?
//            var statement = "continue"
//            var statementLabel: String?

            if let act = symbols.first?.code {
                activation = act
//                statement.append(" \(activation)")
//                statementLabel = activation
            }

            return Symbol(
                code: { symbol in
                    guard
                        case .again(activation: let activation) = symbol.controlFlow,
                        let activation = activation
                    else {
                        return "continue"
                    }

                    return "continue \(activation)"
                },
                children: symbols,
                meta: [.controlFlow(.again(activation: activation))]
            )
        }
    }
}
