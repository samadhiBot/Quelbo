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
            Symbol(id: "north", type: .direction, category: .properties),
            Symbol(id: "east", type: .direction, category: .properties),
            Symbol(id: "west", type: .direction, category: .properties),
            Symbol(id: "south", type: .direction, category: .properties),
            Symbol(id: "northEast", type: .direction, category: .properties),
            Symbol(id: "northWest", type: .direction, category: .properties),
            Symbol(id: "southEast", type: .direction, category: .properties),
            Symbol(id: "southWest", type: .direction, category: .properties),
            Symbol(id: "up", type: .direction, category: .properties),
            Symbol(id: "down", type: .direction, category: .properties),
            Symbol(id: "in", type: .direction, category: .properties),
            Symbol(id: "out", type: .direction, category: .properties),
            Symbol(
                id: "land",
                code: """
                    /// Represents an exit toward land.
                    public static let land = Direction(
                        id: "land",
                        synonyms: ["LAND"]
                    )
                    """,
                type: .direction,
                category: .properties
            ),
        ]

        XCTAssertNoDifference(symbol, Symbol(
            id: "<Directions>",
            code: """
                extension Direction {
                    /// Represents an exit toward land.
                    public static let land = Direction(
                        id: "land",
                        synonyms: ["LAND"]
                    )
                }
                """,
            type: .void,
            category: .directions,
            children: expectedDirections
        ))

        for direction in expectedDirections {
            XCTAssertNoDifference(
                try Game.find(direction.id, category: .properties),
                direction
            )
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
