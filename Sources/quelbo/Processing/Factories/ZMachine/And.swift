//
//  And.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/8/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [AND](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3utoxif)
    /// function.
    class And: ZMachineFactory {
        override class var zilNames: [String] {
            ["AND"]
        }

        override class var parameters: Parameters {
            .oneOrMore(.unknown)
        }

        override class var returnType: Symbol.DataType {
            .bool
        }

        var function: String {
            "and"
        }

        override func process() throws -> Symbol {
            let type = symbols.commonType() ?? .unknown
//            guard [.bool, .int, .object].contains(type) else {
//                throw Error.invalidAndArgumentType(symbols)
//            }

            return Symbol(
                ".\(function)(\(symbols.codeValues(.commaSeparatedNoTrailingComma)))",
                type: type,
                children: symbols
            )
        }
    }
}

// MARK: - Errors

extension Factories.And {
    enum Error: Swift.Error {
        case invalidAndArgumentType([Symbol])
    }
}
