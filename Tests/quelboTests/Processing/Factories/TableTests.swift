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
            <GLOBAL TROLL-MELEE
              <TABLE (PURE)
               <LTABLE (PURE)
                <LTABLE (PURE) "The troll swings his axe, but it misses.">
                <LTABLE (PURE) "The troll's axe barely misses your ear.">>
               <LTABLE (PURE)
                <LTABLE (PURE) "The flat of the troll's axe hits you delicately on the head, knocking
              you out.">>
              >>

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
                    .room("forest1"),
                    .room("forest2"),
                    .room("forest3")
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
                    .object("troll"),
                    .object("sword"),
                    1,
                    0,
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
            code: "Table(0, .int8(0), .int8(0))",
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
                    20,
                    "The candles grow shorter.",
                    10,
                    "The candles are becoming quite short.",
                    5,
                    "The candles won't last long now.",
                    0,
                    flags: .pure
                )
                """,
            type: .tableDeclaration,
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
                    .room("forest1"),
                    .room("forest2"),
                    .room("forest3"),
                    .room("path"),
                    .room("clearing"),
                    .room("forest1"),
                    flags: .pure
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }

    func testFormPureTableWithStrings() throws {
        let symbol = process("""
            <TABLE (PURE) "up to your ankles."
                "up to your shin."
                "up to your knees."
                "up to your hips."
                "up to your waist."
                "up to your chest."
                "up to your neck."
                "over your head."
                "high in your lungs.">
            """)

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
        let symbol = process("""
            <LTABLE <TABLE TROLL SWORD 1 0 TROLL-MELEE>
                <TABLE THIEF KNIFE 1 0 THIEF-MELEE>
                <TABLE CYCLOPS <> 0 0 CYCLOPS-MELEE>>
            """)

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .table(
                        .object("troll"),
                        .object("sword"),
                        1,
                        0,
                        .table(Globals.trollMelee)
                    ),
                    .table(
                        .object("thief"),
                        .object("knife"),
                        1,
                        0,
                        .table(Globals.thiefMelee)
                    ),
                    .table(
                        .object("cyclops"),
                        false,
                        0,
                        0,
                        .table(Globals.cyclopsMelee)
                    ),
                    flags: .length
                )
                """,
            type: .table,
            returnHandling: .implicit
        ))
    }

    func testReferencedTable() throws {
        process("""
            <GLOBAL VILLAINS
              <LTABLE <TABLE TROLL SWORD 1 0 TROLL-MELEE>
                <TABLE THIEF KNIFE 1 0 THIEF-MELEE>
                <TABLE CYCLOPS <> 0 0 CYCLOPS-MELEE>>>
        """)

        XCTAssertNoDifference(
            try Game.find("trollMelee"),
            Statement(
                id: "trollMelee",
                code: #"""
                    var trollMelee = Table(
                        .table(
                            .table(
                                "The troll swings his axe, but it misses.",
                                flags: .length, .pure
                            ),
                            .table(
                                "The troll's axe barely misses your ear.",
                                flags: .length, .pure
                            ),
                            flags: .length, .pure
                        ),
                        .table(
                            .table(
                                """
                                    The flat of the troll's axe hits you delicately on the head, \
                                    knocking you out.
                                    """,
                                flags: .length, .pure
                            ),
                            flags: .length, .pure
                        ),
                        flags: .pure
                    )
                    """#,
                type: .tableDeclaration,
                category: .globals,
                isCommittable: true,
                isMutable: true,
                returnHandling: .implicit
            )
        )

        XCTAssertNoDifference(
            try Game.find("villains"),
            Statement(
                id: "villains",
                code: """
                    var villains = Table(
                        .table(
                            .object("troll"),
                            .object("sword"),
                            1,
                            0,
                            .table(Globals.trollMelee)
                        ),
                        .table(
                            .object("thief"),
                            .object("knife"),
                            1,
                            0,
                            .table(Globals.thiefMelee)
                        ),
                        .table(
                            .object("cyclops"),
                            false,
                            0,
                            0,
                            .table(Globals.cyclopsMelee)
                        ),
                        flags: .length
                    )
                    """,
                type: .tableDeclaration,
                category: .globals,
                isCommittable: true,
                isMutable: true,
                returnHandling: .implicit
            )
        )
    }
}
