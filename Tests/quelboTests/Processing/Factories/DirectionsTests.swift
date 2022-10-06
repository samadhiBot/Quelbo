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
        let symbol = process("<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>")

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
                category: .properties,
                isCommittable: true
            ),
            Statement(
                id: "east",
                code: "",
                type: .direction,
                category: .properties,
                isCommittable: true
            ),
            Statement(
                id: "west",
                code: "",
                type: .direction,
                category: .properties,
                isCommittable: true
            ),
            Statement(
                id: "south",
                code: "",
                type: .direction,
                category: .properties,
                isCommittable: true
            ),
            Statement(
                id: "northEast",
                code: "",
                type: .direction,
                category: .properties,
                isCommittable: true
            ),
            Statement(
                id: "northWest",
                code: "",
                type: .direction,
                category: .properties,
                isCommittable: true
            ),
            Statement(
                id: "southEast",
                code: "",
                type: .direction,
                category: .properties,
                isCommittable: true
            ),
            Statement(
                id: "southWest",
                code: "",
                type: .direction,
                category: .properties,
                isCommittable: true
            ),
            Statement(
                id: "up",
                code: "",
                type: .direction,
                category: .properties,
                isCommittable: true
            ),
            Statement(
                id: "down",
                code: "",
                type: .direction,
                category: .properties,
                isCommittable: true
            ),
            Statement(
                id: "in",
                code: "",
                type: .direction,
                category: .properties,
                isCommittable: true
            ),
            Statement(
                id: "out",
                code: "",
                type: .direction,
                category: .properties,
                isCommittable: true
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
                category: .properties,
                isCommittable: true
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
