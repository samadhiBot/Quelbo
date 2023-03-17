//
//  IsZero.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ZERO?](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1wjtbr7)
    /// function.
    class IsZero: Factory {
        override class var zilNames: [String] {
            ["0?", "ZERO?"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(1))
            )

            let value = symbols[0]

            if value.type.isSomeInteger && value.type.confidence > .integerZero {
                try value.assert(
                    .hasType(.int)
                )
            }



//            if value.type

//            try symbols[0].assert({
//                if symbols[0].type.confidence == .integerZero {
//                    return .hasType(.int)
//                } else if symbols[0].type.dataType == .bool {
//                    return .hasType(.bool)
//                } else {
//                    return .isOptional
//                }
//            }())
        }

        override func process() throws -> Symbol {
            let value = symbols[0]

            return .statement(
                code: { _ in
                    let function: String = {
                        if value.type.dataType == .bool {
                            return "isFalse"
                        } else if value.type.isOptional == true {
                            return "isNil"
                        } else {
                            return "isZero"
                        }
                    }()

                    return "\(value.handle).\(function)"
                },
                type: .bool
//                payload: .init(symbols: symbols)
            )
        }
    }
}
