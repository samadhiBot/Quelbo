//
//  Token.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

/// The set of tokens that can be parsed from ZIL source code.
indirect enum Token: Hashable {
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
    case global(Token)

    /// Represents a Zil list.
    case list([Token])

    /// Represents a Zil local atom.
    case local(String)

    /// Represents a Zil part-of-speech value.
    case partsOfSpeech(String)

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

    /// Represents a Zil verb.
    case verb(String)

    /// Represents a Zil word.
    case word(String)
}

extension Token {
    /// Returns a token's value.
    public var value: String {
        switch self {
        case .atom(let value):         return "\(value)"
        case .bool(let value):         return "\(value)"
        case .character(let value):    return "\(value)"
        case .commented(let token):    return "\(token)"
        case .decimal(let value):      return "\(value)"
        case .eval(let token):         return "\(token)"
        case .form(let tokens):        return "\(tokens.map { $0.value })"
        case .global(let token):       return "\(token.value)"
        case .list(let tokens):        return "\(tokens.map { $0.value })"
        case .local(let value):        return "\(value)"
        case .partsOfSpeech(let value): return "\(value)"
        case .property(let value):     return "\(value)"
        case .quote(let token):        return "\(token)"
        case .segment(let token):      return "\(token)"
        case .string(let value):       return "\(value)"
        case .type(let value):         return "\(value)"
        case .vector(let tokens):      return "\(tokens.map { $0.value })"
        case .verb(let value):         return "\(value)"
        case .word(let value):         return "\(value)"
        }
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        switch self {
        case .atom(let value):         return ".atom(\(value))"
        case .bool(let value):         return ".bool(\(value))"
        case .character(let value):    return ".character(\(value))"
        case .commented(let token):    return ".commented(\(token))"
        case .decimal(let value):      return ".decimal(\(value))"
        case .eval(let token):         return ".eval(\(token))"
        case .form(let tokens):        return ".form(\(tokens.map(\.description).values())"
        case .global(let token):       return ".global(\(token))"
        case .list(let tokens):        return ".list(\(tokens.map(\.description).values())"
        case .local(let value):        return ".local(\(value))"
        case .partsOfSpeech(let value): return ".partsOfSpeech(\(value))"
        case .property(let value):     return ".property(\(value))"
        case .quote(let token):        return ".quote(\(token))"
        case .segment(let token):      return ".segment(\(token))"
        case .string(let value):       return ".string(\(value))"
        case .type(let value):         return ".type(\(value))"
        case .vector(let tokens):      return ".vector(\(tokens.map(\.description).values())"
        case .verb(let value):         return ".verb(\(value))"
        case .word(let value):         return ".word(\(value))"
        }
    }

    var zil: String {
        switch self {
        case .atom(let value):         return value
        case .bool(let value):         return "\(value)"
        case .character(let value):    return value
        case .commented(let token):    return ";\(token.zil)"
        case .decimal(let value):      return "\(value)"
        case .eval(let token):         return "%\(token.zil)"
        case .form(let tokens):        return "<\(tokens.map(\.zil).values())>"
        case .global(let token):       return ",\(token.zil)"
        case .list(let tokens):        return "(\(tokens.map(\.zil).values()))"
        case .local(let value):        return ".\(value)"
        case .partsOfSpeech(let value): return ",PS?\(value)"
        case .property(let value):     return ",P?\(value)"
        case .quote(let token):        return "'\(token.zil)"
        case .segment(let token):      return "\(token.zil)"
        case .string(let value):       return "\"\(value)\""
        case .type(let value):         return "#\(value)"
        case .vector(let tokens):      return "[\(tokens.map(\.zil).values())]"
        case .verb(let value):         return ",V?\(value)"
        case .word(let value):         return ",W?\(value)"
        }
    }
}

extension Array where Element == Token {
    var evaluated: [Token] {
        map { token in
            switch token {
            case .eval(let evalToken):
                return evalToken
            case .form(var formTokens):
                switch formTokens.shift() {
                case .atom("FORM"): return .form(formTokens.evaluated)
                case .atom("LIST"): return .list(formTokens.evaluated)
                default: return token
                }
            case .global(let globalToken):
                return globalToken
            case .quote(let quotedToken):
                return quotedToken
            default:
                return token
            }
        }
    }
}
