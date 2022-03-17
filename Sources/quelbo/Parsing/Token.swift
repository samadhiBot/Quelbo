//
//  Token.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

/// The set of tokens to be parsed from ZIL source code.
indirect enum Token: Equatable {
    case atom(String)
    case bool(Bool)
    // case byte(Int8)
    // case character(Character)
    case commented(Token)
    case decimal(Int)
    case form([Token])
    // case global(Token)
    // case hashed(Token)
    case list([Token])
    // case local(Token)
    // case macro(Token)
    case quoted(Token)
    // case segment(Token)
    case string(String)
    // case table([Token])
    // case vector([Token])
}
