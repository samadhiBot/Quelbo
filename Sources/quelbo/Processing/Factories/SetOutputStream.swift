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
    class SetOutputStream: Factory {
        override class var zilNames: [String] {
            ["DIROUT"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.atLeast(1))
            )

            try symbols[0].assert(
                .hasType(.int)
            )

            guard symbols.count > 1 else { return }
            try symbols[1].assert(
                .hasType(.table)
            )

            guard symbols.count > 2 else { return }
            try symbols[2].assert(
                .hasType(.int)
            )
        }

        override func process() throws -> Symbol {
            var arguments: [String] = []

            let stream = try findStream(symbols[0].code)
            arguments.append(".\(stream.rawValue)")

            if stream == .tableOn {
                try symbols.assert(.haveCount(.atLeast(2)))
                arguments.append("&\(symbols[1].code)")
            }

            return .statement(
                code: { _ in
                    "setOutputStream(\(arguments.values(.commaSeparatedNoTrailingComma)))"
                },
                type: .void
            )
        }
    }
}

extension Factories.SetOutputStream {
    enum Stream: String {
        case screenOff
        case transcriptFileOff
        case tableOff
        case commandsFileOff
        case screenOn
        case transcriptFileOn
        case tableOn
        case commandsFileOn
        case invalid
    }

    func findStream(_ code: String) throws -> Stream {
        switch code {
        case "-1": return .screenOff
        case "-2": return .transcriptFileOff
        case "-3": return .tableOff
        case "-4": return .commandsFileOff
        case "1": return .screenOn
        case "2": return .transcriptFileOn
        case "3": return .tableOn
        case "4": return .commandsFileOn
        default: throw Error.invalidOutputStream(code)
        }
    }
}

extension Factories.SetOutputStream {
    enum Error: Swift.Error {
        case invalidOutputStream(String)
    }
}
