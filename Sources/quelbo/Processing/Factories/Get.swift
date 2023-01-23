//
//  Get.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import Fizmo
import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [GET](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.r2r73f) and
    /// [GETB](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3b2epr8)
    /// functions.
    class Get: Factory {
        override class var zilNames: [String] {
            ["GET", "GETB"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.exactly(2))
            )

            try symbols[0].assert({
                if symbols[0].type.dataType == .object || symbols[0].type.isArray == true {
                    return .isProperty
                } else {
                    return .hasType(.table)
                }
            }())

            try symbols[1].assert(
                .hasType(.int)
            )
        }

        override func process() throws -> Symbol {
            let container = symbols[0]
            let offset = symbols[1]

            return .statement(
                code: { _ in
                    "try \(container.code).get(at: \(offset.code))"
                },
                type: try {
                    switch container.type.dataType {
//                    case .object:
//                        guard container.isProperty else {
//                            throw Error.invalidNonPropertyGet(container)
//                        }
//                        return container.type
                    case .table:
                        guard
                            offset.code == "0",
                            container.payload?.flags.contains(.length) == true
                        else {
                            return .someTableElement
                        }
                        return .int
                    case .word:
                        return .someTableElement
                    default:
//                        throw Error.unknownContainerForGet(container)
                        guard container.isProperty else {
                            throw Error.invalidNonPropertyGet(container)
                        }
                        return container.type
                    }
                }()
            )
        }
    }
}

// MARK: - Errors

extension Factories.Get {
    enum Error: Swift.Error {
        case invalidNonPropertyGet(Symbol)
        case unknownContainerForGet(Symbol)
    }
}
