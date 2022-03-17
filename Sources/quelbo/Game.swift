//
//  Game.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Parsing

struct Game {
    static var definitions: [Muddle.Definition] = []

    let parser: AnyParser<Substring.UTF8View, Array<Token>>
    var tokens: [Token] = []
}
