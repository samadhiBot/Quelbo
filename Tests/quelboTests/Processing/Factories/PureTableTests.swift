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

final class PureTableTests: QuelboTests {
    let factory = Factories.PureTable.self

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
        AssertSameFactory(factory, Game.findFactory("PTABLE"))
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
                    forest1,
                    forest2,
                    forest3,
                    flags: .pure
                )
                """,
            type: .table,
            isMutable: false,
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
                    .object(troll),
                    .object(sword),
                    .int(1),
                    .int(0),
                    .bool(trollMelee),
                    flags: .pure
                )
                """,
            type: .table,
            isMutable: false,
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
                    forest1,
                    forest2,
                    forest3,
                    path,
                    clearing,
                    forest1,
                    flags: .pure
                )
                """,
            type: .table,
            isMutable: false,
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
                        .object(troll),
                        .object(sword),
                        .int(1),
                        .int(0),
                        .bool(trollMelee),
                        flags: .length, .pure
                    ),
                    .table(
                        .object(thief),
                        .object(knife),
                        .int(1),
                        .int(0),
                        .bool(thiefMelee)
                    ),
                    flags: .pure
                )
                """,
            type: .table,
            isMutable: false,
            returnHandling: .implicit
        ))
    }
}
