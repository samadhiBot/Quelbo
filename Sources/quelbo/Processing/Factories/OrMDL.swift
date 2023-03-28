//
//  OrMDL.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/7/23.
//

import Foundation

extension Factories {
    /// A symbol factory for the MDL
    /// [OR](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.11si5id)
    /// function.
    class OrMDL: Factory {
        override class var factoryType: Factories.FactoryType {
            .mdl
        }

        override class var zilNames: [String] {
            ["OR"]
        }

        override func processTokens() throws {
            for token in tokens {
                let symbol = try symbolize(
                    token,
                    mode: .process,
                    type: .mdl
                )
                if symbol == .false {
                    continue
                }
                symbols.append(symbol)
                break
            }
        }

        override func processOrEvaluate() throws -> Symbol {
            guard
                let firstNonFalse = symbols.first(where: { $0 != .false }),
                firstNonFalse != .true
            else {
                return .emptyStatement
            }
            return firstNonFalse
        }
    }
}
