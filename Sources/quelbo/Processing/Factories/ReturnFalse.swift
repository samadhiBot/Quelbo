//
//  ReturnFalse.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [RFALSE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.uzqle7)
    /// function.
    class ReturnFalse: Factory {
        override class var zilNames: [String] {
            ["RFALSE"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(0)))
        }

        override func evaluate() throws -> Symbol {
            return .false
        }

        override func process() throws -> Symbol {
            .statement(
                code: {
                    if $0.type.dataType == .bool {
                        return "return false"
                    }
                    if $0.type.isOptional == true {
                        return "return nil"
                    }
                    return ""
                },
                type: .booleanFalse,
                returnHandling: .forced
            )
        }
    }
}
