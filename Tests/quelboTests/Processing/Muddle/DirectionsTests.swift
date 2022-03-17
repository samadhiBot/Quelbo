//
//  DirectionsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DirectionsTests: XCTestCase {
    func testDirections() throws {
        let directions = Directions([
            .atom("NORTH"),
            .atom("EAST"),
            .atom("WEST"),
            .atom("SOUTH"),
            .atom("NE"),
            .atom("NW"),
            .atom("SE"),
            .atom("SW"),
            .atom("UP"),
            .atom("DOWN"),
            .atom("IN"),
            .atom("OUT"),
            .atom("LAND")
        ])

        XCTAssertNoDifference(
            try directions.process().code,
            """
            enum Directions: String {
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
            """
        )
    }

    func testInvalidDirections() throws {
        let directions = Directions([
            .string("NORTH"),
            .bool(false)
        ])
        XCTAssertThrowsError(try directions.process())
    }
}
