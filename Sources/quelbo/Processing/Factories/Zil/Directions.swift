//
//  Directions.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/22.
//

import Fizmo
import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [DIRECTIONS](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.3ygebqi)
    /// function.
    class Directions: ZilFactory {
        override class var zilNames: [String] {
            ["DIRECTIONS"]
        }

        override class var parameters: Parameters {
            .oneOrMore(.direction)
        }

        override class var returnType: Symbol.DataType {
            .void
        }

        override func processTokens() throws {
            var tokens = tokens
            while let dir = try? findNameSymbol(in: &tokens) {
                var code = ""
                var name = dir.code
                let zil = dir.id.rawValue
                if let fizmoDirection = Direction.find(zil) {
                    name = fizmoDirection.id.description
                } else {
                    code = """
                        /// Represents an exit toward \(name).
                        public static let \(name) = Direction(
                            id: "\(name)",
                            synonyms: ["\(zil)"]
                        )
                        """
                }
                symbols.append(Symbol(
                    id: .init(rawValue: name),
                    code: code,
                    type: .direction,
                    category: .properties
                ))
            }
            guard tokens.isEmpty else {
                throw Error.unconsumedDirectionTokens(self.tokens)
            }
            guard !symbols.isEmpty else {
                throw Error.noDirectionsDefined(self.tokens)
            }
            try Game.commit(symbols)
        }

        override func process() throws -> Symbol {
            let customDirections = symbols.filter { !$0.code.isEmpty }
            let symbol = Symbol(
                id: "<Directions>",
                code: """
                    extension Direction {
                    \(customDirections.codeValues(.singleLineBreak, .indented))
                    }
                    """,
                type: .void,
                category: .directions,
                children: symbols
            )
            return symbol
        }
    }
}

// MARK: - Errors

extension Factories.Directions {
    enum Error: Swift.Error {
        case noDirectionsDefined([Token])
        case unconsumedDirectionTokens([Token])
    }
}
