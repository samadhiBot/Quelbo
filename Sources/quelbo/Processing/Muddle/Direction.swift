//
//  Direction.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/18/22.
//

import Foundation

enum Direction: String {
    case northEast = "NE"
    case northWest = "NW"
    case southEast = "SE"
    case southWest = "SW"
    case `in` = "IN"
}

extension Direction {
    static func `case`(for zilName: String) -> String {
        let direction = Direction.name(for: zilName)
        return """
        case \(direction) = "\(zilName)"
        """
    }

    static func name(for zilName: String) -> String {
        guard let direction = Direction(rawValue: zilName) else {
            return zilName.lowerCamelCase
        }
        switch direction {
        case .northEast: return "northEast"
        case .northWest: return "northWest"
        case .southEast: return "southEast"
        case .southWest: return "southWest"
        case .in:        return "`in`"
        }
    }
}
