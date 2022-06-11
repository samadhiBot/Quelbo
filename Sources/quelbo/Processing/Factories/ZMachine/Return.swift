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
            if var value = symbols.first {
                if value.type.isUnknown {
                    if value.id == "t" {
                        value = .trueSymbol
                    } else if let saved = types[value.id] {
                        value = value.with(type: saved)
                    }
                }
                return Symbol(
                    id: "<Return>",
                    code: "return \(value.code)",
                    type: value.type,
                    children: [value]
                )
            }

            switch blockType {
            case .blockWithActivation,
                 .blockWithDefaultActivation,
                 .repeatingWithActivation,
                 .repeatingWithDefaultActivation:
                return versioned(breakSymbol())
            case .blockWithoutDefaultActivation,
                 .repeatingWithoutDefaultActivation:
                return breakSymbol("defaultAct")
            case .none:
                return returnTrueSymbol
            }
        }
    }
}

extension Factories.Return {
    func breakSymbol(_ activation: String? = nil) -> Symbol {
        guard let activation = activation else {
            return Symbol(id: "<Return>", code: "break")
        }
        return Symbol(id: "<Return>", code: "break \(activation)")
    }

    func continueSymbol(_ activation: String? = nil) -> Symbol {
        guard let activation = activation else {
            return Symbol(id: "<Return>", code: "continue")
        }
        return Symbol(id: "<Return>", code: "continue \(activation)")
    }

    var returnTrueSymbol: Symbol {
        Symbol(
            id: "<Return>",
            code: "return true",
            type: .bool,
            children: [.trueSymbol]
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
