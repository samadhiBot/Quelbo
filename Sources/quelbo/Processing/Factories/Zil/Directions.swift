//
//  Directions.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/22.
//

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

        override func process() throws -> Symbol {
            let directions: [Symbol] = symbols.map { symbol in
                var id = symbol.id
                var code = "case \(symbol.id)"
                if let improved = Improved(rawValue: symbol.id) {
                    id = improved.name
                    code = "case \(improved.name) = \"\(symbol.id)\""
                }
                return Symbol(
                    id: id,
                    code: code,
                    type: .direction,
                    category: .directions,
                    children: symbol.children
                )
            }

            let symbol = Symbol(
                """
                    /// The set of possible movement directions.
                    public enum Direction: String {
                    \(directions.codeValues(lineBreaks: 1).indented)
                    }
                    """,
                type: .void,
                children: directions
            )
            try Game.commit(directions)
            return symbol
        }
    }
}

extension Factories.Directions {
    enum Improved: String {
        case northEast = "ne"
        case northWest = "nw"
        case southEast = "se"
        case southWest = "sw"
        case into      = "in"

        var name: String {
            switch self {
            case .northEast: return "northEast"
            case .northWest: return "northWest"
            case .southEast: return "southEast"
            case .southWest: return "southWest"
            case .into:      return "into"
            }
        }
    }
}
