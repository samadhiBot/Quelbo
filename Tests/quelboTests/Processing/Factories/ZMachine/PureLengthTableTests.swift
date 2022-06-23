//
//  PureLengthTableTests.swift
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

        try! Game.commit(
            Symbol(id: "clearing", type: .object, category: .rooms),
            Symbol(id: "forest1", type: .object, category: .rooms),
            Symbol(id: "forest2", type: .object, category: .rooms),
            Symbol(id: "forest3", type: .object, category: .rooms),
            Symbol(id: "knife", type: .object, category: .objects),
            Symbol(id: "path", type: .object, category: .rooms),
            Symbol(id: "sword", type: .object, category: .objects),
            Symbol(id: "thief", type: .object, category: .objects),
            Symbol(id: "thiefMelee", type: .bool, category: .routines),
            Symbol(id: "troll", type: .object, category: .objects),
            Symbol(id: "trollMelee", type: .bool, category: .routines)
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PLTABLE"))
    }

    func testPureLengthTableOfRooms() throws {
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
                    flags: [.length, .pure]
                )
                """,
            type: .table
        ))
    }

    func testPureLengthTableOfDifferentTypes() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .atom("SWORD"),
            .decimal(1),
            .decimal(0),
            .atom("TROLL-MELEE")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    .object(troll),
                    .object(sword),
                    .int(1),
                    .int(0),
                    .bool(trollMelee),
                    flags: [.length, .pure]
                )
                """,
            type: .table
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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    .room(forest1),
                    .room(forest2),
                    .room(forest3),
                    .room(path),
                    .room(clearing),
                    .room(forest1),
                    flags: [.length, .pure]
                )
                """,
            type: .table
        ))
    }

    func testNestedPureLengthTables() throws {
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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    .table(Table(
                        .object(troll),
                        .object(sword),
                        .int(1),
                        .int(0),
                        .bool(trollMelee),
                        flags: [.length, .pure]
                    )),
                    .table(Table(
                        .object(thief),
                        .object(knife),
                        .int(1),
                        .int(0),
                        .bool(thiefMelee)
                    )),
                    flags: [.length, .pure]
                )
                """,
            type: .table
        ))
    }
}
