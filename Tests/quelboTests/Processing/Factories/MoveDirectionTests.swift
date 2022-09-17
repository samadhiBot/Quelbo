//
//  MoveDirectionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/31/22.
//

import Foundation

import CustomDump
import XCTest
@testable import quelbo

final class MoveDirectionTests: QuelboTests {
    let factory = Factories.MoveDirection.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .statement(
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
        ])
    }

    func testMoveDirectionToRoom() throws {
        let symbol = try factory.init([
            .atom("NORTH"),
            .atom("TO"),
            .atom("NORTH-OF-HOUSE")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".north: .to(northOfHouse)",
            type: .direction
        ))
    }

    func testMoveNovelDirectionToRoom() throws {
        let symbol = try factory.init([
            .atom("LAND"),
            .atom("TO"),
            .atom("STREAM-VIEW")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".land: .to(streamView)",
            type: .direction
        ))
    }

    func testMoveDirectionToRoomPerFunction() throws {
        let symbol = try factory.init([
            .atom("UP"),
            .atom("PER"),
            .atom("UP-CHIMNEY-FUNCTION")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".up: .per(upChimneyFunc)",
            type: .direction
        ))
    }

    func testMoveDirectionBlocked() throws {
        let symbol = try factory.init([
            .atom("EAST"),
            .string("The door is boarded and you can't remove the boards.")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                .east: .blocked("The door is boarded and you can't remove the boards.")
                """,
            type: .direction
        ))
    }

    func testMoveDirectionSorry() throws {
        let symbol = try factory.init([
            .atom("NORTH"),
            .atom("SORRY"),
            .string("You've only just arrived, and besides, the weather outside seems to be getting worse.")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"""
                .north: .blocked("""
                    You've only just arrived, and besides, the weather outside \
                    seems to be getting worse.
                    """)
                """#,
            type: .direction
        ))
    }

    func testMoveDirectionConditional() throws {
        let symbol = try factory.init([
            .atom("SW"),
            .atom("TO"),
            .atom("STONE-BARROW"),
            .atom("IF"),
            .atom("WON-FLAG")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".southWest: .conditional(stoneBarrow, if: wonFlag)",
            type: .direction
        ))
    }

    func testMoveDirectionConditionalElse() throws {
        let symbol = try factory.init([
            .atom("NORTH"),
            .atom("TO"),
            .atom("RESERVOIR"),
            .atom("IF"),
            .atom("LOW-TIDE"),
            .atom("ELSE"),
            .string("You would drown.")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                .north: .conditionalElse(reservoir,
                    if: lowTide,
                    else: "You would drown."
                )
                """,
            type: .direction
        ))
    }

    func testMoveDirectionConditionalIs() throws {
        let symbol = try factory.init([
            .atom("WEST"),
            .atom("TO"),
            .atom("KITCHEN"),
            .atom("IF"),
            .atom("KITCHEN-WINDOW"),
            .atom("IS"),
            .atom("OPEN")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".west: .conditional(kitchen, if: kitchenWindow.isOpen)",
            type: .direction
        ))
    }

    func testInvalidPrepositionThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("NORTH"),
                .atom("TOWARD"),
                .atom("NORTH-OF-HOUSE")
            ], with: &localVariables)
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(42),
                .atom("TO"),
                .atom("NORTH-OF-HOUSE")
            ], with: &localVariables)
        )
    }
}
