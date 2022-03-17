//
//  Routine+Code.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/10/22.
//

import Foundation

extension Routine {
    struct Code {
        var tokens: [Token]
        let nestLevel: Int

        init(_ tokens: [Token], nestLevel: Int = 0) {
            self.tokens = tokens
            self.nestLevel = nestLevel
        }
    }
}

extension Routine.Code {
    enum Err: Error {
        case missingCommand(String)
    }

    mutating func process() throws -> String {
        var code: [String] = []
        while !tokens.isEmpty {
            if let atom = tokens.shiftAtom() {
                let variable = try atom.process()
                code.append(
                    (tokens.isEmpty ? "return \(variable)" : variable).indented(nestLevel)
                )
            } else if let token = tokens.shift() {
                code.append(
                    try token.process().indented(nestLevel)
                )
            }
        }
        return code.joined(separator: "\n")
    }
}
