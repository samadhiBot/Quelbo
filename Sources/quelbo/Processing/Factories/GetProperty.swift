//
//  GetProperty.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GETP](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1q7ozz1) and
    /// [GETPT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.4a7cimu)
    /// functions.
    class GetProperty: Factory {
        override class var zilNames: [String] {
            ["GETP", "GETPT"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2))
            )

            try symbols[0].assert(
                .hasType(.object)
            )

            try symbols[1].assert(
                .isProperty
            )
        }

        override func process() throws -> Symbol {
            let object = symbols[0]
            let property = symbols[1]
            let isDirectProperty: Bool
            let type: TypeInfo

            if case .property = tokens[1] {
                isDirectProperty = true
                type = property.type.property
            } else {
                isDirectProperty = false
                type = .unknown.property
            }

            return .statement(
                code: { _ in
                    if isDirectProperty {
                        return "\(object.handle).\(property.code)"
                    } else {
                        return "\(object.handle).property(\(property.code))"
                    }
                },
                type: type,
                payload: .init(
                    symbols: symbols
                )
            )
        }
    }
}
