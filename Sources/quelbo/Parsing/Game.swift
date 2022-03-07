//
//  Game.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Parsing

struct Game {
    let parser: AnyParser<Substring.UTF8View, Array<Syntax.Token>>
    var tokens: [Syntax.Token] = []

    init() {
        let syntax = Syntax().parser

        let parser = Parse {
            Many {
                syntax
            } separator: {
                Whitespace()
            }
            End()
        }
        .eraseToAnyParser()

        self.parser = parser
    }

    mutating func parse(_ source: String) throws {
        let fileTokens = try parser.parse(source)
        tokens.append(contentsOf: fileTokens)
    }
}
