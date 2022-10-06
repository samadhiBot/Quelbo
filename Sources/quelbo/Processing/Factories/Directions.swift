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
    class Directions: Factory {
        override class var zilNames: [String] {
            ["DIRECTIONS"]
        }

        override func processSymbols() throws {
            try symbols.assert([
                .haveCount(.atLeast(1)),
                .haveType(.direction),
            ])
        }

        override func processTokens() throws {
            var tokens = tokens

            while let zilName = try? findName(in: &tokens) {
                var code = ""
                var name = zilName.lowerCamelCase

                if let fizmoDirection = Direction.find(zilName) {
                    name = fizmoDirection.id.description
                } else {
                    code = """
                        /// Represents an exit toward \(name).
                        public static let \(name) = Direction(
                            id: "\(name)",
                            synonyms: ["\(zilName)"]
                        )
                        """
                }

                symbols.append(.statement(
                    id: name,
                    code: { _ in
                        code
                    },
                    type: .direction,
                    category: .properties,
                    isCommittable: true
                ))
            }

            guard tokens.isEmpty else {
                throw Error.unconsumedDirectionTokens(self.tokens)
            }

            guard !symbols.isEmpty else {
                throw Error.noDirectionsDefined(self.tokens)
            }
        }

        override func process() throws -> Symbol {
            let customDirections = symbols.filter { !$0.code.isEmpty }

            return .statement(
                code: { _ in
                    """
                    extension Direction {
                    \(customDirections.codeValues(.singleLineBreak, .indented))
                    }
                    """
                },
                type: .void,
                children: symbols,
                category: .directions
            )
        }
    }
}

// MARK: - Errors

extension Factories.Directions {
    enum Error: Swift.Error {
        case missingDirectionID(Symbol)
        case noDirectionsDefined([Token])
        case unconsumedDirectionTokens([Token])
    }
}
