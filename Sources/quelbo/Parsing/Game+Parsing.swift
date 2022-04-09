//
//  Game+Parsing.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Parsing

extension Game {
    mutating func parse(_ source: String) throws {
        let fileTokens = try parser.parse(source)
        gameTokens.append(contentsOf: fileTokens)
    }
}
