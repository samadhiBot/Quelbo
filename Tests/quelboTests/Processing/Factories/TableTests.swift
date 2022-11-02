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
                    .room(forest1),
                    .room(forest2),
                    .room(forest3)
                )
                """,
            type: .table,
            isMutable: true
        ))
    }

    func testTableOfDifferentTypes() throws {
        let symbol = process("<TABLE TROLL SWORD 1 0 TROLL-MELEE>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                Table(
                    .object(troll),
                    .object(sword),
                    .int(1),
                    .int(0),
                    .table(trollMelee)
                )
                """,
            type: .table,
            isMutable: true
        ))
    }

    func testByteLengthTable() throws {
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
            code: """
                Table(
                    flags: [.byte, .length],
                    .int(1),
                    .int(2),
                    .int(3),
                    .int(4)
                )
                """,
            type: .table,
            isMutable: true
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
            code: """
            Table(
                .int(0),
                .int8(0),
                .int8(0)
            )
            """,
            type: .table,
            isMutable: true
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
                    flags: [.pure],
                    .room(forest1),
                    .room(forest2),
                    .room(forest3),
                    .room(path),
                    .room(clearing),
                    .room(forest1)
                )
                """,
            type: .table,
            isMutable: false
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
                    flags: [.pure],
                    .string("up to your ankles."),
                    .string("up to your shin."),
                    .string("up to your knees."),
                    .string("up to your hips."),
                    .string("up to your waist."),
                    .string("up to your chest."),
                    .string("up to your neck."),
                    .string("over your head."),
                    .string("high in your lungs.")
                )
                """,
            type: .table,
            isMutable: false
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
                        .object(troll),
                        .object(sword),
                        .int(1),
                        .int(0),
                        .table(trollMelee)
                    ),
                    .table(
                        .object(thief),
                        .object(knife),
                        .int(1),
                        .int(0),
                        .table(thiefMelee)
                    )
                )
                """,
            type: .table,
            isMutable: true
        ))
    }
}