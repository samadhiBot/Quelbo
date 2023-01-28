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
    class Flags: Factory {
        override class var factoryType: FactoryType {
            .property
        }

        override class var zilNames: [String] {
            ["FLAGS"]
        }

        override func processTokens() throws {
            var tokens = tokens

            while let token = tokens.shift() {
                switch token {
                case .commented:
                    continue

                case .atom(let zil):
                    if let flag = Game.flags.find(zil) {
                        symbols.append(.statement(flag))
                        continue
                    }

                    let fizmoFlag = Flag.find(zil.lowerCamelCase)

                    let flagSymbol: Symbol = .statement(
                        id: fizmoFlag.zil,
                        code: { _ in
                            ".\(fizmoFlag.id.description)"
                        },
                        type: .bool,
                        category: .flags,
                        isCommittable: true
                    )

                    symbols.append(flagSymbol)

                default:
                    throw Error.invalidFlagToken(token)
                }
            }
        }

        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "flags" },
                    type: .bool.array
                )
            }

            let flags = symbols.sorted

            return .statement(
                code: { _ in
                    "flags: [\(flags.codeValues(.commaSeparated))]"
                },
                type: .bool.array,
                payload: .init(
                    symbols: symbols
                )
            )
        }
    }
}

// MARK: - Errors

extension Factories.Flags {
    enum Error: Swift.Error {
        case invalidFlagToken(Token)
    }
}
