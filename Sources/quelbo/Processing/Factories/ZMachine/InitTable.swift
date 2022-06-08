//
//  InitTable.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import Foundation
import Fizmo

extension Factories {
    /// A symbol factory for the Zil
    /// [ITABLE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3s49zyc)
    /// function.
    class InitTable: Table {
        override class var zilNames: [String] {
            ["ITABLE"]
        }

        override class var parameters: Parameters {
            .oneOrMore(.zilElement)
        }

        var specifiesByteOrWord: Bool = false

        override var isLengthTable: Bool {
            specifiesByteOrWord
        }

        override func processTokens() throws {
            var tokens = tokens

            self.specifiesByteOrWord = fetchSpecifier(&tokens)
            let count = try fetchCount(&tokens)
            let valueSymbol = try symbolize(tokens.shift() ?? .decimal(0))

            guard count > 0 else {
                throw Error.countMustBeGreaterThanZero
            }

            (0..<count).forEach { _ in
                symbols.append(valueSymbol)
            }

            checkFlags()
        }
    }
}

extension Factories.InitTable {
    enum Error: Swift.Error {
        case countMustBeGreaterThanZero
        case missingCount
    }

    func fetchCount(_ tokens: inout [Token]) throws -> Int {
        guard case .decimal(let count) = tokens.shift() else {
            throw Error.missingCount
        }
        return count
    }

    func fetchSpecifier(_ tokens: inout [Token]) -> Bool {
        switch tokens.first {
        case .atom("BYTE"), .atom("WORD"):
            tokens.removeFirst()
            return true
        case .atom("NONE"):
            tokens.removeFirst()
            return false
        case .list(var specifiers):
            tokens.removeFirst()
            return fetchSpecifier(&specifiers)
        default:
            return false
        }
    }
}
