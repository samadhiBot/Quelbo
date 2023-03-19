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

    func testDirectionsWithOneCustom() throws {
        process("""
            <DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>
        """)

        XCTAssertNoDifference(
            Game.directions.find("_customDirections_"),
            Statement(
                id: "_customDirections_",
                code: """
                    /// Represents an exit toward land.
                    public static let land = Direction(id: "land")
                    """,
                type: .void,
                category: .directions,
                isCommittable: true
            )
        )
    }

    func testFizmoDirectionsOnly() throws {
        process("""
            <DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT>
        """)

        XCTAssertNoDifference(
            Game.directions.find("_customDirections_"),
            Statement(
                id: "_customDirections_",
                code: "",
                type: .void,
                category: .directions,
                isCommittable: true
            )
        )
    }

    func testExpectedDirections() throws {
        process("""
            <DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>
        """)

        for direction in Self.expectedDirections {
            XCTAssertNoDifference(
                Game.properties.find(direction.id!),
                direction
            )
        }
    }

    func testDirectionsComparison() throws {
        let symbol = process("""
            <DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>

            <EQUAL? ,PRSO ,P?LAND ,P?EAST ,P?WEST>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: "Globals.parsedDirectObject.equals(land, east, west)",
            type: .bool
        ))
    }

    func testInvalidDirections() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("NORTH"),
            ], with: &localVariables).process()
        )
    }
}

// MARK: - Test helpers

extension DirectionsTests {
    static let expectedDirections = [
        Statement(
            id: "north",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "east",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "west",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "south",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "northEast",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "northWest",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "southEast",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "southWest",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "up",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "down",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "in",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "out",
            code: "",
            type: .object,
            category: .properties,
            isCommittable: true
        ),
        Statement(
            id: "land",
            code: """
                /// Represents an exit toward land.
                public static let land = Direction(id: "land")
                """,
            type: .object,
            category: .properties,
            isCommittable: true
        ),
    ]
}
