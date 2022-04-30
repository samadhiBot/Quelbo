//
//  Direction.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/22/22.
//

import Foundation

/// The set of possible movement directions.
/// 
public enum Direction: String {
    case north = "NORTH"
    case east = "EAST"
    case west = "WEST"
    case south = "SOUTH"
    case northEast = "NE"
    case northWest = "NW"
    case southEast = "SE"
    case southWest = "SW"
    case up = "UP"
    case down = "DOWN"
    case `in` = "IN"
    case out = "OUT"
    case land = "LAND"
}
