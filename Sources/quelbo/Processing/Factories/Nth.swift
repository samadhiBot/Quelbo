//
//  Nth.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [NTH](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.odc9jc)
    /// function.
    class Nth: Factory {
        override class var zilNames: [String] {
            ["NTH"]
        }

        override func processSymbols() throws {
            try symbols.assert(.haveCount(.exactly(2)))

            try symbols[1].assert(.hasType(.int))
        }

        override func process() throws -> Symbol {
            let values = symbols[0]
            let index = symbols[1]

            var elementType: TypeInfo
            if case .array(let type) = values.type.dataType {
                elementType = .init(dataType: type, confidence: .certain)
            } else {
                elementType = values.type
            }

            return .statement(
                code: { _ in
                    "\(values.code).nthElement(\(index.code))"
                },
                type: elementType
            )
        }
    }
}
