//
//  PrintCharacter.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [PRINTC](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1jvko6v) and
    /// [PRINTU](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2wfod1i)
    /// functions.
    class PrintCharacter: Print {
        override class var zilNames: [String] {
            ["PRINTC", "PRINTU"]
        }

        override class var parameters: Parameters {
            .one(.unknown)
        }

        override class var returnType: Symbol.DataType {
            .void
        }

        override func process() throws -> Symbol {
            let value = symbols[0]
            switch value.type {
            case .int:
                return Symbol("output(utf8: \(value.code))", type: .void, children: symbols)
            case .string:
                return Symbol("output(\(value.code))", type: .void, children: symbols)
            default:
                throw Error.invalidPrintCharacterValue(value)
            }
        }
    }
}

// MARK: - Errors

extension Factories.PrintCharacter {
    enum Error: Swift.Error {
        case invalidPrintCharacterValue(Symbol)
    }
}
