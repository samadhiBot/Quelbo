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

        override func process() throws -> Symbol {
            let symbols = symbols
            var confidence: DataType.Confidence? {
                symbols
                    .map { $0.confidence ?? .unknown }
                    .max()
            }
            var type: DataType {
                let types = symbols.map(\.type).unique

                switch types.count {
                case 0: return .array(.unknown)
                case 1: return .array(types[0] ?? .unknown)
                default: return .array(.zilElement)
                }
            }

            return .statement(
                code: { _ in
                    "[\(symbols.codeValues(.commaSeparated))]"
                },
                type: type,
                confidence: confidence
            )
        }
    }
}
