//
//  Game+Categories.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

extension Game {
    /// Returns an array of game symbols representing routines referenced in an object or room
    /// definition.
    static var actions: [Symbol] {
        let objects = shared.symbols.filter { [.objects, .rooms].contains($0.category) }
        return objects.reduce(into: []) { actions, object in
            for property in object.payload?.symbols ?? [] {
                guard
                    property.type == .object.property,
                    !actions.contains(object)
                else { continue }

                actions.append(object)
            }
        }
    }

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
