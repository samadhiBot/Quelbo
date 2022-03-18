//
//  Game+Process.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

extension Game {
    mutating func process() throws {
        try tokens.forEach { token in
            switch token {
            case .atom:             break // ignored
            case .bool:             throw Err.unexpectedAtRootLevel(token)
            case .commented:        break // ignored
            case .decimal:          throw Err.unexpectedAtRootLevel(token)
            case .form(let tokens): try processForm(tokens)
            case .list:             throw Err.unexpectedAtRootLevel(token)
            case .quoted:           throw Err.unexpectedAtRootLevel(token)
            case .string:           break // ignored
            }
        }
    }

    var output: String {
        let directions = Self.directions
            .map { $0.code }
            .joined(separator: "\n")

        let globals = Self.globals
            .sorted { $0.name < $1.name }
            .map { $0.code }
            .joined(separator: "\n\n")

        let objects = Self.objects
            .sorted { $0.name < $1.name }
            .map { $0.code }
            .joined(separator: "\n\n")

        let rooms = Self.rooms
            .sorted { $0.name < $1.name }
            .map { $0.code }
            .joined(separator: "\n\n")

        let routines = Self.routines
            .sorted { $0.name < $1.name }
            .map { $0.code }
            .joined(separator: "\n\n")

        return """
        // Directions

        \(directions)

        // Globals

        struct World {
        \(globals.indented())
        }

        // Routines

        \(routines)

        // Objects

        \(objects)

        // Rooms

        \(rooms)
        
        """
    }
}

extension Game {
    enum Err: Error {
        case unexpectedAtRootLevel(Token)
        case unknownDirective([Token])
        case unknownOperation(String)
    }

    mutating func processForm(_ formTokens: [Token]) throws {
        var tokens = formTokens
        guard case .atom(let directive) = tokens.shiftAtom() else {
            throw Err.unknownDirective(tokens)
        }
        guard let muddle = Muddle(rawValue: directive) else {
            throw Err.unknownOperation("\(directive): \(tokens)")
        }
        if let definition = try muddle.process(tokens) {
            Self.definitions.append(definition)
        }
    }
}

extension Game {
    static var directions: [Muddle.Definition] {
        definitions.filter { $0.defType == .directions }
    }

    static var globals: [Muddle.Definition] {
        definitions.filter { $0.defType == .global }
    }

    static var objects: [Muddle.Definition] {
        definitions.filter { $0.defType == .object }
    }

    static var rooms: [Muddle.Definition] {
        definitions.filter { $0.defType == .room }
    }

    static var routines: [Muddle.Definition] {
        definitions.filter { $0.defType == .routine }
    }
}
