//
//  DirectionsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DirectionsTests: QuelboTests {
    let factory = Factories.Directions.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("DIRECTIONS"))
    }

    func testDirections() throws {
        let symbol = try factory.init([
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
        ]).process()

        let expectedDirections = [
            Symbol(id: "north", code: "case north", type: .direction, category: .directions),
            Symbol(id: "east", code: "case east", type: .direction, category: .directions),
            Symbol(id: "west", code: "case west", type: .direction, category: .directions),
            Symbol(id: "south", code: "case south", type: .direction, category: .directions),
            Symbol(id: "northEast", code: #"case northEast = "ne""#, type: .direction, category: .directions),
            Symbol(id: "northWest", code: #"case northWest = "nw""#, type: .direction, category: .directions),
            Symbol(id: "southEast", code: #"case southEast = "se""#, type: .direction, category: .directions),
            Symbol(id: "southWest", code: #"case southWest = "sw""#, type: .direction, category: .directions),
            Symbol(id: "up", code: "case up", type: .direction, category: .directions),
            Symbol(id: "down", code: "case down", type: .direction, category: .directions),
            Symbol(id: "into", code: #"case into = "in""#, type: .direction, category: .directions),
            Symbol(id: "out", code: "case out", type: .direction, category: .directions),
            Symbol(id: "land", code: "case land", type: .direction, category: .directions),
        ]

        XCTAssertNoDifference(symbol, Symbol(
            """
                /// The set of possible movement directions.
                public enum Direction: String {
                    case north
                    case east
                    case west
                    case south
                    case northEast = "ne"
                    case northWest = "nw"
                    case southEast = "se"
                    case southWest = "sw"
                    case up
                    case down
                    case into = "in"
                    case out
                    case land
                }
                """,
            type: .void,
            children: expectedDirections
        ))
        try expectedDirections.forEach { direction in
            XCTAssertNoDifference(try Game.find(direction.id, category: .directions), direction)
        }
    }

    func testInvalidDirections() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("NORTH"),
            ]).process()
        )
    }
}
