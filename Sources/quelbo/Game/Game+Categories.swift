//
//  Game+Categories.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

extension Game {
    /// Returns an array of game symbols in the ``Symbol/Category/constants`` category.
    static var constants: [Symbol] {
        shared.symbols.filter { $0.category == .constants }
    }

    /// Returns an array of game symbols in the ``Symbol/Category/directions`` category.
    static var directions: [Symbol] {
        shared.symbols.filter { $0.category == .directions }
    }

    /// Returns an array of game symbols in the ``Symbol/Category/flags`` category.
    static var flags: [Symbol] {
        shared.symbols.filter { $0.category == .flags }
    }

    /// Returns an array of game symbols in the ``Symbol/Category/globals`` category.
    static var globals: [Symbol] {
        shared.symbols.filter { $0.category == .globals }
    }

    /// Returns an array of game symbols in the ``Symbol/Category/objects`` category.
    static var objects: [Symbol] {
        shared.symbols.filter { $0.category == .objects }
    }

    /// Returns an array of game symbols in the ``Symbol/Category/objects`` category.
    static var properties: [Symbol] {
        shared.symbols.filter { $0.category == .properties }
    }

    /// Returns an array of game symbols in the ``Symbol/Category/rooms`` category.
    static var rooms: [Symbol] {
        shared.symbols.filter { $0.category == .rooms }
    }

    /// Returns an array of game symbols in the ``Symbol/Category/routines`` category.
    static var routines: [Symbol] {
        shared.symbols.filter { $0.category == .routines }
    }

    /// Returns an array of game symbols in the ``Symbol/Category/syntax`` category.
    static var syntax: [Symbol] {
        shared.symbols.filter { $0.category == .syntax }
    }
}

extension Game {
    /// Returns an array of game symbols in the ``Symbol/Category/routines`` category, where each
    /// symbol represents an action routine referenced by an object or room.
    static var actionRoutines: [Symbol] {
        routines.filter {
            guard case .statement(let statement) = $0 else { return false }

            return statement.isActionRoutine
        }
    }

    /// Returns an array of game symbols in the ``Symbol/Category/routines`` category, where each
    /// symbol represents a routine that is not referenced by an object or room.
    static var nonActionRoutines: [Symbol] {
        routines.filter {
            guard case .statement(let statement) = $0 else { return false }

            return !statement.isActionRoutine
        }
    }
}
