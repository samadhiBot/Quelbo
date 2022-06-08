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
    }

    func testTableOfRooms() throws {
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
                    .room(forest3)
                )
                """,
            type: .table,
            children: [
                Symbol(id: "forest1", code: ".room(forest1)", type: .zilElement, category: .rooms),
                Symbol(id: "forest2", code: ".room(forest2)", type: .zilElement, category: .rooms),
                Symbol(id: "forest3", code: ".room(forest3)", type: .zilElement, category: .rooms),
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
                Table(
                    .object(troll),
                    .object(sword),
                    .int(1),
                    .int(0),
                    .bool(trollMelee)
                )
                """,
            type: .table,
            children: [
                Symbol(id: "troll", code: ".object(troll)", type: .zilElement, category: .objects),
                Symbol(id: "sword", code: ".object(sword)", type: .zilElement, category: .objects),
                Symbol(id: "1", code: ".int(1)", type: .zilElement, meta: [.isLiteral]),
                Symbol(id: "0", code: ".int(0)", type: .zilElement, meta: [.isLiteral, .maybeEmptyValue]),
                Symbol(id: "trollMelee", code: ".bool(trollMelee)", type: .zilElement, category: .routines),
            ]
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
        ]).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            """
            Table(
                .int(1),
                .int(2),
                .int(3),
                .int(4),
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

        XCTAssertNoDifference(symbol, Symbol(
            """
                Table(
                    .room(forest1),
                    .room(forest2),
                    .room(forest3),
                    .room(path),
                    .room(clearing),
                    .room(forest1),
                    isMutable: false
                )
                """,
            type: .table,
            children: [
                Symbol(id: "forest1", code: ".room(forest1)", type: .zilElement, category: .rooms),
                Symbol(id: "forest2", code: ".room(forest2)", type: .zilElement, category: .rooms),
                Symbol(id: "forest3", code: ".room(forest3)", type: .zilElement, category: .rooms),
                Symbol(id: "path", code: ".room(path)", type: .zilElement, category: .rooms),
                Symbol(id: "clearing", code: ".room(clearing)", type: .zilElement, category: .rooms),
                Symbol(id: "forest1", code: ".room(forest1)", type: .zilElement, category: .rooms),
                Symbol("isMutable: false"),
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
                Table(
                    .table(Table(
                        .object(troll),
                        .object(sword),
                        .int(1),
                        .int(0),
                        .bool(trollMelee)
                    )),
                    .table(Table(
                        .object(thief),
                        .object(knife),
                        .int(1),
                        .int(0),
                        .bool(thiefMelee)
                    ))
                )
                """,
            type: .table,
            children: [
                Symbol(
                    id: """
                        Table(
                            .object(troll),
                            .object(sword),
                            .int(1),
                            .int(0),
                            .bool(trollMelee)
                        )
                        """,
                    code: """
                        .table(Table(
                            .object(troll),
                            .object(sword),
                            .int(1),
                            .int(0),
                            .bool(trollMelee)
                        ))
                        """,
                    type: .zilElement,
                    children: [
                        Symbol(id: "troll", code: ".object(troll)", type: .zilElement, category: .objects),
                        Symbol(id: "sword", code: ".object(sword)", type: .zilElement, category: .objects),
                        Symbol(id: "1", code: ".int(1)", type: .zilElement, meta: [.isLiteral]),
                        Symbol(id: "0", code: ".int(0)", type: .zilElement, meta: [.isLiteral, .maybeEmptyValue]),
                        Symbol(id: "trollMelee", code: ".bool(trollMelee)", type: .zilElement, category: .routines),
                    ]
                ),
                Symbol(
                    id: """
                        Table(
                            .object(thief),
                            .object(knife),
                            .int(1),
                            .int(0),
                            .bool(thiefMelee)
                        )
                        """,
                    code: """
                        .table(Table(
                            .object(thief),
                            .object(knife),
                            .int(1),
                            .int(0),
                            .bool(thiefMelee)
                        ))
                        """,
                    type: .zilElement,
                    children: [
                        Symbol(id: "thief", code: ".object(thief)", type: .zilElement, category: .objects),
                        Symbol(id: "knife", code: ".object(knife)", type: .zilElement, category: .objects),
                        Symbol(id: "1", code: ".int(1)", type: .zilElement, meta: [.isLiteral]),
                        Symbol(id: "0", code: ".int(0)", type: .zilElement, meta: [.isLiteral, .maybeEmptyValue]),
                        Symbol(id: "thiefMelee", code: ".bool(thiefMelee)", type: .zilElement, category: .routines),
                    ]
                ),
            ]
        ))
    }
}
