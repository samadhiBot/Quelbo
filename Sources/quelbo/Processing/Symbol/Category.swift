//
//  Category.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/2/22.
//

import Foundation

/// The set of ``Symbol`` categories.
///
/// Categories are used to distinguish different kinds of symbols, allowing them to be grouped
/// together appropriately in the game translation.
enum Category: String {
    /// Symbols representing global constant game values.
    case constants

    /// Symbols representing definitions that are evaluated to create other symbols.
    case definitions

    /// Symbols representing room exit directions.
    case directions

    /// Symbols representing object flags.
    case flags

    /// Symbols representing global game variables.
    case globals

    /// Symbols representing objects in the game.
    case objects

    /// Symbols representing object properties.
    case properties

    /// Symbols representing rooms (i.e. locations) in the game.
    case rooms

    /// Symbols representing routines defined by the game.
    case routines

    /// Symbols representing syntax declarations specified by the game.
    case syntax
}

extension Category {
    /// Returns a human-readable name for the category.
    var name: String {
        switch self {
        case .constants: return "constant"
        case .definitions: return "definition"
        case .directions: return "direction"
        case .flags: return "flag"
        case .globals: return "global"
        case .objects: return "object"
        case .properties: return "property"
        case .rooms: return "room"
        case .routines: return "routine"
        case .syntax: return "syntax"
        }
    }
}
