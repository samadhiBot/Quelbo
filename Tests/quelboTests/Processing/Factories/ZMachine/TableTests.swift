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
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("TABLE"))
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("LTABLE"))
    }

    func testTableOfRooms() throws {
        let symbol = try factory.init([
            .atom("FOREST-1"),
            .atom("FOREST-2"),
            .atom("FOREST-3"),
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                [
                    .room(forest1),
                    .room(forest2),
                    .room(forest3),
                ]
                """,
            type: .array(.tableElement),
            children: [
                Symbol(id: "forest1", code: ".room(forest1)", type: .tableElement, category: .rooms),
                Symbol(id: "forest2", code: ".room(forest2)", type: .tableElement, category: .rooms),
                Symbol(id: "forest3", code: ".room(forest3)", type: .tableElement, category: .rooms),
            ]
        ))
    }

    func testTableOfDifferentTypes() throws {
        let symbol = try factory.init([
            .atom("TROLL"),
            .atom("SWORD"),
            .decimal(1),
            .decimal(0),
            .atom("TROLL-MELEE")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                [
                    .object(troll),
                    .object(sword),
                    .int(1),
                    .int(0),
                    .bool(trollMelee),
                ]
                """,
            type: .array(.tableElement),
            children: [
                Symbol(id: "troll", code: ".object(troll)", type: .tableElement, category: .objects),
                Symbol(id: "sword", code: ".object(sword)", type: .tableElement, category: .objects),
                Symbol(id: "1", code: ".int(1)", type: .tableElement),
                Symbol(id: "0", code: ".int(0)", type: .tableElement),
                Symbol(id: "trollMelee", code: ".bool(trollMelee)", type: .tableElement, category: .routines),
            ]
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
                [
                    .room(forest1),
                    .room(forest2),
                    .room(forest3),
                    .room(path),
                    .room(clearing),
                    .room(forest1),
                ]
                """,
            type: .array(.tableElement),
            children: [
                Symbol(id: "forest1", code: ".room(forest1)", type: .tableElement, category: .rooms),
                Symbol(id: "forest2", code: ".room(forest2)", type: .tableElement, category: .rooms),
                Symbol(id: "forest3", code: ".room(forest3)", type: .tableElement, category: .rooms),
                Symbol(id: "path", code: ".room(path)", type: .tableElement, category: .rooms),
                Symbol(id: "clearing", code: ".room(clearing)", type: .tableElement, category: .rooms),
                Symbol(id: "forest1", code: ".room(forest1)", type: .tableElement, category: .rooms),
            ]
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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                [
                    .table([
                        .object(troll),
                        .object(sword),
                        .int(1),
                        .int(0),
                        .bool(trollMelee),
                    ]),
                    .table([
                        .object(thief),
                        .object(knife),
                        .int(1),
                        .int(0),
                        .bool(thiefMelee),
                    ]),
                ]
                """,
            type: .array(.tableElement),
            children: [
                Symbol(
                    id: """
                        [
                            .object(troll),
                            .object(sword),
                            .int(1),
                            .int(0),
                            .bool(trollMelee),
                        ]
                        """,
                    code: """
                        .table([
                            .object(troll),
                            .object(sword),
                            .int(1),
                            .int(0),
                            .bool(trollMelee),
                        ])
                        """,
                    type: .tableElement,
                    children: [
                        Symbol(id: "troll", code: ".object(troll)", type: .tableElement, category: .objects),
                        Symbol(id: "sword", code: ".object(sword)", type: .tableElement, category: .objects),
                        Symbol(id: "1", code: ".int(1)", type: .tableElement),
                        Symbol(id: "0", code: ".int(0)", type: .tableElement),
                        Symbol(id: "trollMelee", code: ".bool(trollMelee)", type: .tableElement, category: .routines),
                    ]
                ),
                Symbol(
                    id: """
                        [
                            .object(thief),
                            .object(knife),
                            .int(1),
                            .int(0),
                            .bool(thiefMelee),
                        ]
                        """,
                    code: """
                        .table([
                            .object(thief),
                            .object(knife),
                            .int(1),
                            .int(0),
                            .bool(thiefMelee),
                        ])
                        """,
                    type: .tableElement,
                    children: [
                        Symbol(id: "thief", code: ".object(thief)", type: .tableElement, category: .objects),
                        Symbol(id: "knife", code: ".object(knife)", type: .tableElement, category: .objects),
                        Symbol(id: "1", code: ".int(1)", type: .tableElement),
                        Symbol(id: "0", code: ".int(0)", type: .tableElement),
                        Symbol(id: "thiefMelee", code: ".bool(thiefMelee)", type: .tableElement, category: .routines),
                    ]
                ),
            ]
        ))
    }
}
