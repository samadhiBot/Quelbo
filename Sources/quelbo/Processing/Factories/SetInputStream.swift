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
    class SetInputStream: Factory {
        override class var zilNames: [String] {
            ["DIRIN"]
        }

        override func processTokens() throws {
            try super.processTokens()

            guard let stream = symbols.shift() else {
                throw Error.missingInputStream(tokens)
            }

            var flag: String? {
                switch stream.code {
                case "0": return ".keyboard"
                case "1": return ".file"
                default: return nil
                }
            }

            guard let flag = flag else {
                throw Error.invalidInputStream(stream.code)
            }

            symbols.insert(
                .statement(
                    code: { _ in flag },
                    type: .int
                ),
                at: 0
            )
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.exactly(1)),
                .haveType(.int)
            ])
        }

        override func process() throws -> Symbol {
            let stream = symbols.codeValues(.commaSeparatedNoTrailingComma)

            return .statement(
                code: { _ in
                    "setInputStream(\(stream))"
                },
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
