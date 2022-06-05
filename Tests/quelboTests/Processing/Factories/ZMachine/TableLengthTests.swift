//
//  TableLengthTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/3/22.
//

import Foundation

import CustomDump
import XCTest
@testable import quelbo

final class TableLengthTests: QuelboTests {
    let factory = Factories.TableLength.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
            Symbol("clearing", type: .object, category: .rooms),
            Symbol("forest1", type: .object, category: .rooms),
            Symbol("forest2", type: .object, category: .rooms),
            Symbol("forest3", type: .object, category: .rooms),
            Symbol("knife", type: .object, category: .objects),
            Symbol("path", type: .object, category: .rooms),
            Symbol("sword", type: .object, category: .objects),
            Symbol("thief", type: .object, category: .objects),
            Symbol("thiefMelee", type: .bool, category: .routines),
            Symbol("troll", type: .object, category: .objects),
            Symbol("trollMelee", type: .bool, category: .routines)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("LTABLE"))
    }

    func testLengthTableOfRooms() throws {
        let symbol = try factory.init([
            .atom("FOREST-1"),
            .atom("FOREST-2"),
            .atom("FOREST-3"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    .room(forest1),
                    .room(forest2),
                    .room(forest3),
                    hasLengthFlag: true
                )
                """,
            type: .table,
            children: [
                Symbol(id: "forest1", code: ".room(forest1)", type: .zilElement, category: .rooms),
                Symbol(id: "forest2", code: ".room(forest2)", type: .zilElement, category: .rooms),
                Symbol(id: "forest3", code: ".room(forest3)", type: .zilElement, category: .rooms),
                Symbol("hasLengthFlag: true"),
            ]
        ))
    }

    func testLengthTableOfDifferentTypes() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .atom("SWORD"),
            .decimal(1),
            .decimal(0),
            .atom("TROLL-MELEE")
        ]).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            """
                Table(
                    .object(troll),
                    .object(sword),
                    .int(1),
                    .int(0),
                    .bool(trollMelee),
                    hasLengthFlag: true
                )
                """,
            type: .table
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
        ]).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            """
                Table(
                    .room(forest1),
                    .room(forest2),
                    .room(forest3),
                    .room(path),
                    .room(clearing),
                    .room(forest1),
                    isMutable: false,
                    hasLengthFlag: true
                )
                """,
            type: .table
        ))
    }

    func testNestedLengthTables() throws {
        let symbol = try factory.init([
            .form([
                .atom("LTABLE"),
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
        ]).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            """
                Table(
                    .table(Table(
                        .object(troll),
                        .object(sword),
                        .int(1),
                        .int(0),
                        .bool(trollMelee),
                        hasLengthFlag: true
                    )),
                    .table(Table(
                        .object(thief),
                        .object(knife),
                        .int(1),
                        .int(0),
                        .bool(thiefMelee)
                    )),
                    hasLengthFlag: true
                )
                """,
            type: .table
        ))
    }
}