//
//  TableTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/7/22.
//

import Foundation

import CustomDump
import XCTest
@testable import quelbo

final class TableTests: QuelboTests {
    let factory = Factories.Table.self

    override func setUp() {
        super.setUp()

        process("""
            <CONSTANT MISSED 1>        ;"attacker misses"

            <GLOBAL CYCLOPS-MELEE <TABLE (PURE) "Cyclops melee message">>
            <GLOBAL DEF1 <TABLE (PURE) MISSED MISSED MISSED MISSED>>
            <GLOBAL THIEF-MELEE <TABLE (PURE) "Thief melee message">>
            <GLOBAL TROLL-MELEE <TABLE (PURE) "Troll melee message">>
            <OBJECT CYCLOPS><OBJECT KNIFE><OBJECT SWORD><OBJECT THIEF><OBJECT TROLL>
            <ROOM CLEARING><ROOM FOREST1><ROOM FOREST2><ROOM FOREST3><ROOM PATH>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("TABLE"))
    }

    func testTableOfRooms() throws {
        let symbol = process("<TABLE FOREST-1 FOREST-2 FOREST-3>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .room("Rooms.forest1"),
                    .room("Rooms.forest2"),
                    .room("Rooms.forest3")
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }

    func testTableOfDifferentTypes() throws {
        let symbol = process("<TABLE TROLL SWORD 1 0 TROLL-MELEE>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .object("Objects.troll"),
                    .object("Objects.sword"),
                    .int(1),
                    .int(0),
                    .table(Globals.trollMelee)
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }

    func testByteTable() throws {
        let symbol = try factory.init([
            .list([
                .atom("BYTE"),
                .atom("LENGTH")
            ]),
            .decimal(1),
            .decimal(2),
            .decimal(3),
            .decimal(4)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Table(1, 2, 3, 4, flags: .byte, .length)",
            type: .table,
            returnHandling: .implicit
        ))
    }

    func testWithByteElementsTable() throws {
        let symbol = try factory.init([
            .decimal(0),
            .type("BYTE"),
            .decimal(0),
            .type("BYTE"),
            .decimal(0)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Table(.int(0), .int8(0), .int8(0))",
            type: .table,
            returnHandling: .implicit
        ))
    }

    func testPureTable() throws {
        let symbol = process("""
            <GLOBAL CANDLE-TABLE
                <TABLE (PURE)
                       20
                       "The candles grow shorter."
                       10
                       "The candles are becoming quite short."
                       5
                       "The candles won't last long now."
                       0>>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "candleTable",
            code: """
                var candleTable = Table(
                    .int(20),
                    .string("The candles grow shorter."),
                    .int(10),
                    .string("The candles are becoming quite short."),
                    .int(5),
                    .string("The candles won't last long now."),
                    .int(0),
                    flags: .pure
                )
                """,
            type: .table.root,
            category: .globals,
            isCommittable: true,
            isMutable: true,
            returnHandling: .implicit
        ))
    }

    func testFormPureTable() throws {
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
                    flags: .pure
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }

    func testFormPureTableWithStrings() throws {
        let symbol = try factory.init([
            .list([
                .atom("PURE")
            ]),
            .string("up to your ankles."),
            .string("up to your shin."),
            .string("up to your knees."),
            .string("up to your hips."),
            .string("up to your waist."),
            .string("up to your chest."),
            .string("up to your neck."),
            .string("over your head."),
            .string("high in your lungs.")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    "up to your ankles.",
                    "up to your shin.",
                    "up to your knees.",
                    "up to your hips.",
                    "up to your waist.",
                    "up to your chest.",
                    "up to your neck.",
                    "over your head.",
                    "high in your lungs.",
                    flags: .pure
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }

    func testNestedTable() throws {
        let symbol = try factory.init([
            .form([
                .atom("TABLE"),
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
                        .table(Globals.trollMelee)
                    ),
                    .table(
                        .object("Objects.thief"),
                        .object("Objects.knife"),
                        .int(1),
                        .int(0),
                        .table(Globals.thiefMelee)
                    )
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }
}
