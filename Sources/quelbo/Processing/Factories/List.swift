//
//  List.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/4/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [LIST](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4iylrwe)
    /// function.
    class List: Factory {
        override class var zilNames: [String] {
            ["LIST"]
        }

        override func processSymbols() throws {
            try? symbols.assert(
                .haveCommonType
            )
        }

        override func evaluate() throws -> Symbol {
            .definition(
                id: "%list",
                tokens: tokens
            )
        }

        override func process() throws -> Symbol {
            let typeInfo: TypeInfo = {
                let types = symbols.nonCommentSymbols.map(\.type).unique
                switch types.count {
                case 0: return .unknown.array
                case 1: return types[0].array
                default: return .someTableElement.array
                }
            }()

            return .statement(
                code: {
                    "[\($0.payload.symbols.handles(.commaSeparated))]"
                },
                type: typeInfo,
                payload: .init(
                    symbols: symbols
                )
            )
        }
    }
}
