//
//  PureTableTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/3/22.
//

import Foundation

import CustomDump
import XCTest
@testable import quelbo

final class PureLengthTableTests: QuelboTests {
    let factory = Factories.PureLengthTable.self

    override func setUp() {
        super.setUp()

        process("""
            <OBJECT KNIFE>
            <OBJECT SWORD>
            <OBJECT THIEF>
            <OBJECT TROLL>
            <ROOM CLEARING>
            <ROOM FOREST1>
            <ROOM FOREST2>
            <ROOM FOREST3>
            <ROOM PATH>
            <ROUTINE THIEF-MELEE () T>
            <ROUTINE TROLL-MELEE () T>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("PLTABLE"))
    }

    func testPureTableOfRooms() throws {
        let symbol = try factory.init([
            .atom("FOREST-1"),
            .atom("FOREST-2"),
            .atom("FOREST-3"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .room("Rooms.forest1"),
                    .room("Rooms.forest2"),
                    .room("Rooms.forest3"),
                    flags: .length, .pure
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }

    func testPureTableOfDifferentTypes() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .atom("SWORD"),
            .decimal(1),
            .decimal(0),
            .atom("TROLL-MELEE")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .object("Objects.troll"),
                    .object("Objects.sword"),
                    .int(1),
                    .int(0),
                    .bool(Routines.trollMelee),
                    flags: .length, .pure
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }

    func testPureLengthTableWithLeadingZero() throws {
        let symbol = process("""
            <GLOBAL JUMPLOSS
                <PLTABLE 0
                       "You should have looked before you leaped."
                       "In the movies, your life would be passing before your eyes."
                       "Geronimo...">>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "jumploss",
            code: """
                var jumploss = Table(
                    "You should have looked before you leaped.",
                    "In the movies, your life would be passing before your eyes.",
                    "Geronimo...",
                    flags: .length, .pure
                )
                """,
            type: .table.root,
            category: .globals,
            isCommittable: true,
            isMutable: true
        ))
    }

    func testFormPureLTable() throws {
        let symbol = try factory.init([
            .list([
                .atom("PURE")
            ]),
            .atom("FOREST-1"),
            .atom("FOREST-2"),
            .atom("FOREST-3"),
            .atom("PATH"),
            .atom("CLEARING"),
            .atom("FOREST-1"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .room("Rooms.forest1"),
                    .room("Rooms.forest2"),
                    .room("Rooms.forest3"),
                    .room("Rooms.path"),
                    .room("Rooms.clearing"),
                    .room("Rooms.forest1"),
                    flags: .length, .pure
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }

    func testNestedPureTables() throws {
        let symbol = try factory.init([
            .form([
                .atom("PLTABLE"),
                .atom("TROLL"),
                .atom("SWORD"),
                .decimal(1),
                .decimal(0),
                .atom("TROLL-MELEE")
            ]),
            .form([
                .atom("TABLE"),
                .atom("THIEF"),
                .atom("KNIFE"),
                .decimal(1),
                .decimal(0),
                .atom("THIEF-MELEE")
            ]),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .table(
                        .object("Objects.troll"),
                        .object("Objects.sword"),
                        .int(1),
                        .int(0),
                        .bool(Routines.trollMelee),
                        flags: .length, .pure
                    ),
                    .table(
                        .object("Objects.thief"),
                        .object("Objects.knife"),
                        .int(1),
                        .int(0),
                        .bool(Routines.thiefMelee)
                    ),
                    flags: .length, .pure
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }
}
