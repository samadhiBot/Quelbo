//
//  Directions.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

/// `Directions` creates words in the vocabulary with the part-of-speech `DIRECTION`.
///
/// Refer to the [ZILF Reference Guide](https://bit.ly/3hTXqdh) for details.
struct Directions {
    var tokens: [Token]

    init(_ tokens: [Token]) {
        self.tokens = tokens
    }
}

extension Directions {
    enum Err: Error {
        case unexpectedTokenType
    }

    func process() throws -> Muddle.Definition {
        .init(
            name: "Directions",
            code: """
                /// The set of possible movement directions.
                public enum Direction: String {
                \(try directions().indented())
                }
                """,
            dataType: .direction,
            defType: .directions,
            isMutable: false
        )
    }
}

fileprivate extension Directions {
    func directions() throws -> String {
        try tokens.map { (token: Token) -> String in
            guard case .atom(let zilName) = token else {
                throw Err.unexpectedTokenType
            }
            return Direction.case(for: zilName)
        }
        .joined(separator: "\n")
    }
}
