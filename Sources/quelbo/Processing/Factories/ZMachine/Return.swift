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
            var metaData: Set<Symbol.MetaData> = []
//            if let blockType = blockType {
//                metaData.insert(.blockType(blockType))
//            }

            guard var value = symbols.shift() else {
                metaData.insert(.controlFlow(.return(activation: nil)))
                return Symbol(
                    code: { symbol in
                        guard case .return(activation: let activation) = symbol.controlflow else {
                            return "Not a code block"
                        }

                        if Game.shared.zMachineVersion > .z3 {
                            return "return true"
                        }
                        if let activation = activation {
                            return "break \(activation)"
                        }
                        return "break"
//                        print("// 🥥 \(symbol.blockType)")
//                        if case .block(activation: let activation) = symbol.controlflow {
//
//                        }
//                        case .blockWithoutActivation, .repeatingWithoutActivation, .none:
//                            return "break"
//                        case .blockWithActivation(let activation):
//                            if Game.shared.zMachineVersion.intValue <= 4 {
//                                return "break \(activation)"
//                            } else {
//                                return "return true"
//                            }
//                        case .repeatingWithActivation(let activation):
//                            if Game.shared.zMachineVersion.intValue <= 4 {
//                                return "break \(activation)"
//                            } else {
//                                return "return true"
//                            }
//                        }
//                        case .again(activation: let activation):
//                            <#code#>
//                        case .block(activation: let activation):
//                            <#code#>
//                        case .return(activation: let activation):
//                            <#code#>
//                        case .returnValue(type: let type):
//                            <#code#>
                    },
                    meta: metaData
                )
            }
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
            metaData.insert(.controlFlow(.returnValue(type: value.type)))

            return Symbol(
                code: { symbol in
                    "return \(symbol.children[0].code)"
                },
                type: value.type,
                children: [value],
                meta: metaData
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
            meta: [.controlFlow(.returnValue(type: .bool))]
        )
    }

//    func versioned(_ symbol: Symbol) -> Symbol {
//        if Game.shared.zMachineVersion.intValue <= 4 {
//            return symbol
//        } else {
//            return returnTrueSymbol
//        }
//    }
}
