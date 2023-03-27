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
            <GLOBAL THIEF-MELEE <TABLE (PURE) "Thief melee message">>
            <GLOBAL TROLL-MELEE <TABLE (PURE) "Troll melee message">>
            <OBJECT KNIFE>
            <OBJECT SWORD>
            <OBJECT THIEF>
            <OBJECT TROLL>
            <ROOM CLEARING>
            <ROOM FOREST1>
            <ROOM FOREST2>
            <ROOM FOREST3>
            <ROOM PATH>
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
                    .room("forest1"),
                    .room("forest2"),
                    .room("forest3"),
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
                    .object("troll"),
                    .object("sword"),
                    1,
                    0,
                    .table(Globals.trollMelee),
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
                /// The `jumploss` (JUMPLOSS) 􀎠􀁮Table global.
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
                    .room("forest1"),
                    .room("forest2"),
                    .room("forest3"),
                    .room("path"),
                    .room("clearing"),
                    .room("forest1"),
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
                        .object("troll"),
                        .object("sword"),
                        1,
                        0,
                        .table(Globals.trollMelee),
                        flags: .length, .pure
                    ),
                    .table(
                        .object("thief"),
                        .object("knife"),
                        1,
                        0,
                        .table(Globals.thiefMelee)
                    ),
                    flags: .length, .pure
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }
}
