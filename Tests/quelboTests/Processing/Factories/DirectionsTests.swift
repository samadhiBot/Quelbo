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
        AssertSameFactory(factory, Game.findFactory("DIRECTIONS"))
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
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
            category: .directions
        ))

        let expectedDirections = [
            Statement(
                id: "north",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
                id: "east",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
                id: "west",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
                id: "south",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
                id: "northEast",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
                id: "northWest",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
                id: "southEast",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
                id: "southWest",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
                id: "up",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
                id: "down",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
                id: "in",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
                id: "out",
                code: "",
                type: .direction,
                category: .properties
            ),
            Statement(
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

        for direction in expectedDirections {
            XCTAssertNoDifference(
                Game.properties.find(direction.id!),
                direction
            )
        }
    }

    func testInvalidDirections() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("NORTH"),
            ], with: &localVariables).process()
        )
    }
}
