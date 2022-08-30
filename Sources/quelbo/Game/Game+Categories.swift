//
//  Game+Categories.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

extension Game {
    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/constants`` category.
    static var constants: [Symbol] {
        shared.symbols
            .filter { $0.category == .constants }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/directions`` category.
    static var directions: [Symbol] {
        shared.symbols
            .filter { $0.category == .directions }
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/flags`` category.
    static var flags: [Symbol] {
        shared.symbols
            .filter { $0.category == .flags }
            .sorted
    }

//    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/functions`` category.
//    static var functions: [Symbol] {
//        shared.symbols
//            .filter { $0.category == .functions }
//            .sorted
//    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/globals`` category.
    static var globals: [Symbol] {
        shared.symbols
            .filter { $0.category == .globals }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/objects`` category.
    static var objects: [Symbol] {
        shared.symbols
            .filter { $0.category == .objects }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/objects`` category.
    static var properties: [Symbol] {
        shared.symbols
            .filter { $0.category == .properties }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/rooms`` category.
    static var rooms: [Symbol] {
        shared.symbols
            .filter { $0.category == .rooms }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/routines`` category.
    static var routines: [Symbol] {
        shared.symbols
            .filter { $0.category == .routines }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/syntax`` category.
    static var syntax: [Symbol] {
        shared.symbols
            .filter { $0.category == .syntax }
            .sorted
    }
}
