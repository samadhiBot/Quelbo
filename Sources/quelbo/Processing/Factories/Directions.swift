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
            try symbols.assert(
                .haveCount(.atLeast(1)),
                .haveType(.object)
            )
        }

        override func processTokens() throws {
            var tokens = tokens

            while !tokens.isEmpty {
                let zilName = try findName(in: &tokens)
                var code = ""
                var name = zilName.lowerCamelCase

                if let fizmoDirection = Direction.find(zilName) {
                    name = fizmoDirection.id.description
                } else {
                    code = """
                        /// Represents an exit toward \(name).
                        public static let \(name) = Direction(id: "\(name)")
                        """
                }

                let direction = Statement(
                    id: name,
                    code: { _ in code },
                    type: .object,
                    category: .properties,
                    isCommittable: true
                )

                symbols.append(.statement(direction))
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
                id: "_customDirections_",
                code: { _ in
                    guard !customDirections.isEmpty else { return "" }

                    return customDirections.codeValues(.doubleLineBreak)
                },
                type: .void,
                payload: .init(
                    symbols: symbols
                ),
                category: .directions,
                isCommittable: true
            )
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
