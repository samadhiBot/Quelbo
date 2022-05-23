//
//  MapFirst.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [MAPF](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.vq8v1tpbcqxn)
    /// function.
    class MapFirst: MuddleFactory {
        override class var zilNames: [String] {
            ["MAPF"]
        }

        var mappedTokens: [Token] = []

        override func processTokens() throws {
            var tokens = tokens
            guard
                let finalFunc = tokens.shift(),
                let applicable = tokens.shift()
            else {
                throw FactoryError.missingParameters(self.tokens)
            }
            self.mappedTokens.append(finalFunc)

            let applied: [Token] = processArgs(tokens).map { tokens in
                .form([applicable] + tokens)
            }
            self.mappedTokens.append(contentsOf: applied)
        }

        override func process() throws -> Symbol {
            try symbolizeForm(mappedTokens)
        }
    }
}

extension Factories.MapFirst {
    func processArgs(_ tokens: [Token]) -> [[Token]] {
        guard !tokens.isEmpty else { return [] }

        var args: [[Token]] = []
        var index = 0

        while index >= 0 {
            var argTokens: [Token] = []
            for token in tokens {
                switch token {
                case .list(let listTokens):
                    guard index < listTokens.count else {
                        return args
                    }
                    argTokens.append(listTokens[index])
                case .vector(let vectorTokens):
                    guard index < vectorTokens.count else {
                        return args
                    }
                    argTokens.append(vectorTokens[index])
                default:
                    argTokens.append(token)
                    index = .min
                }
            }
            args.append(argTokens)
            index += 1
        }
        return args
    }
}
