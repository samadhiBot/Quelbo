//
//  Token.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

/// The set of tokens that can be parsed from ZIL source code.
indirect enum Token: Equatable {
    /// Represents a Zil atom.
    case atom(String)

    /// Represents a Zil boolean value.
    case bool(Bool)

    /// Represents a Zil character.
    case character(String)

    /// Represents a commented Zil token.
    case commented(Token)

    /// Represents a Zil decimal integer value.
    case decimal(Int)

    /// Represents a Zil token that hasn't yet been evaluated.
    case eval(Token)

    /// Represents a Zil form.
    case form([Token])

    /// Represents a Zil global atom.
    case global(String)

    /// Represents a Zil list.
    case list([Token])

    /// Represents a Zil local atom.
    case local(String)

    /// Represents a Zil object property.
    case property(String)

    /// Represents a Zil quoted token.
    case quote(Token)

    /// Represents a Zil segment token.
    case segment(Token)

    /// Represents a Zil string value.
    case string(String)

    /// Represents a Zil change type.
    case type(String)

    /// Represents a Zil vector.
    case vector([Token])
}

extension Token {
    /// Returns a token's value.
    public var value: String {
        switch self {
        case .atom(let value):       return "\(value)"
        case .bool(let value):       return "\(value)"
        case .character(let value):  return "\(value)"
        case .commented(let token):  return "\(token)"
        case .decimal(let value):    return "\(value)"
        case .eval(let token):       return "\(token)"
        case .form(let tokens):      return "\(tokens.map { $0.value })"
        case .global(let value):     return "\(value)"
        case .list(let tokens):      return "\(tokens.map { $0.value })"
        case .local(let value):      return "\(value)"
        case .property(let value):   return "\(value)"
        case .quote(let token):      return "\(token)"
        case .segment(let token):    return "\(token)"
        case .string(let value):     return "\(value)"
        case .type(let value):       return "\(value)"
        case .vector(let tokens):    return "\(tokens.map { $0.value })"
        }
    }
}
