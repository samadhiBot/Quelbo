//
//  SetOutputStream.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/19/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [DIROUT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.26sx1u5)
    /// function.
    class SetOutputStream: ZMachineFactory {
        override class var zilNames: [String] {
            ["DIROUT"]
        }

        override class var parameters: Parameters {
            .three(.int, .optional(.table), .optional(.int))
        }

        override func processTokens() throws {
            try super.processTokens()

            guard let stream = symbols.shift() else {
                throw Error.missingOutputStream(tokens)
            }

            switch stream.code {
            case "-1": symbols.insert(Symbol(".screenOff"), at: 0)
            case "-2": symbols.insert(Symbol(".transcriptFileOff"), at: 0)
            case "-3": symbols.insert(Symbol(".tableOff"), at: 0)
            case "-4": symbols.insert(Symbol(".commandsFileOff"), at: 0)
            case "1": symbols.insert(Symbol(".screenOn"), at: 0)
            case "2": symbols.insert(Symbol(".transcriptFileOn"), at: 0)
            case "3": symbols.insert(Symbol(".tableOn"), at: 0)
            case "4": symbols.insert(Symbol(".commandsFileOn"), at: 0)
            default: throw Error.invalidOutputStream(stream.code)
            }
        }

        override func process() throws -> Symbol {
            Symbol(
                "setOutputStream(\(symbols.codeValues(.commaSeparatedNoTrailingComma)))",
                type: .void
            )
        }
    }
}

extension Factories.SetOutputStream {
    enum Error: Swift.Error {
        case invalidOutputStream(String)
        case missingOutputStream([Token])
    }
}
