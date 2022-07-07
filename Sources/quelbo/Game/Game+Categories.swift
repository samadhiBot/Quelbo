//
//  Game+Categories.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

extension Game {
    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/directions`` category.
    static var directions: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .directions }
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/constants`` category.
    static var constants: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .constants }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/globals`` category.
    static var globals: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .globals }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/functions`` category.
    static var functions: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .functions }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/objects`` category.
    static var objects: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .objects }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/rooms`` category.
    static var rooms: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .rooms }
            .sorted
    }

    /// Returns an array of game symbols in the ``Symbol/Category-swift.enum/routines`` category.
    static var routines: [Symbol] {
        shared.gameSymbols
            .filter { $0.category == .routines }
            .sorted
    }
}
