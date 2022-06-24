//
//  SetInputStream.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/18/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [DIRIN](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3rnmrmc)
    /// function.
    class SetInputStream: ZMachineFactory {
        override class var zilNames: [String] {
            ["DIRIN"]
        }

        override class var parameters: Parameters {
            .one(.int)
        }

        override func processTokens() throws {
            try super.processTokens()

            guard let stream = symbols.shift() else {
                throw Error.missingInputStream(tokens)
            }

            switch stream.code {
            case "0": symbols.insert(Symbol(".keyboard"), at: 0)
            case "1": symbols.insert(Symbol(".file"), at: 0)
            default: throw Error.invalidInputStream(stream.code)
            }
        }

        override func process() throws -> Symbol {
            Symbol(
                "setInputStream(\(symbols.codeValues()))",
                type: .void
            )
        }
    }
}

extension Factories.SetInputStream {
    enum Error: Swift.Error {
        case invalidInputStream(String)
        case missingInputStream([Token])
    }
}
