//
//  Return.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/23/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [RETURN](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2fugb6e)
    /// function.
    class Return: ZMachineFactory {
        override class var zilNames: [String] {
            ["RETURN", "RETURN!-"]
        }

        override class var parameters: Parameters {
            .zeroOrMore(.unknown)
        }

        override func process() throws -> Symbol {
            if var value = symbols.shift() {
//                if value.typeCertainty < .certain {
//                    if value.id == "t" {
//                        value = .trueSymbol
//                    } else if let registered = findRegistered(value.id) {
//                        value = registered
////                        value = value.with(type: registered.type)
//                    }
//                }
                if value.typeCertainty < .certain,
                   value.isIdentifiable,
                   let registered = findRegistered(value.id)
                {
                    value = registered
                }

                return Symbol(
                    code: { symbol in
                        "return \(symbol.children[0].code)"
                    },
                    type: value.type,
                    children: [value],
                    meta: [.isReturnStatement(value.type)]
                )
            }

            return Symbol(
                code: { symbol in
                    switch symbol.blockType {
                    case .blockWithActivation(let activation):
                        if Game.shared.zMachineVersion.intValue <= 4 {
                            return "break \(activation)"
                        } else {
                            return "return true"
                        }
                    case .blockWithDefaultActivation, .repeatingWithDefaultActivation:
                        if Game.shared.zMachineVersion.intValue <= 4 {
                            return "break"
                        } else {
                            return "return true"
                        }
                    case .blockWithoutDefaultActivation, .none, .repeatingWithoutDefaultActivation:
                        return "break defaultAct"
                    case .repeatingWithActivation(let activation):
                        return "break \(activation)"
                    }
                },
                meta: [.isReturnStatement(nil)]
            )

//            switch blockType {
//            case .blockWithActivation,
//                 .blockWithDefaultActivation,
//                 .repeatingWithActivation,
//                 .repeatingWithDefaultActivation:
//                return versioned(breakSymbol())
//            case .blockWithoutDefaultActivation,
//                 .repeatingWithoutDefaultActivation:
//                return breakSymbol("defaultAct")
//            case .none:
//                return returnTrueSymbol
//            }
        }
    }
}

extension Factories.Return {
    func breakSymbol(_ activation: String? = nil) -> Symbol {
        guard let activation = activation else {
            return Symbol(code: "break")
        }
        return Symbol(code: "break \(activation)")
    }

    func continueSymbol(_ activation: String? = nil) -> Symbol {
        guard let activation = activation else {
            return Symbol(code: "continue")
        }
        return Symbol(code: "continue \(activation)")
    }

    var returnTrueSymbol: Symbol {
        Symbol(
            code: "return true",
            type: .bool,
            children: [.trueSymbol],
            meta: [.isReturnStatement(.bool)]
        )
    }

    func versioned(_ symbol: Symbol) -> Symbol {
        if Game.shared.zMachineVersion.intValue <= 4 {
            return symbol
        } else {
            return returnTrueSymbol
        }
    }
}
