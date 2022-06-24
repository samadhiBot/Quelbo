//
//  ConstantTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ConstantTests: QuelboTests {
    let factory = Factories.Constant.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(id: "clearing", type: .object, category: .rooms),
            Symbol(id: "cyclops", type: .object, category: .objects),
            Symbol(id: "cyclopsMelee", type: .bool, category: .routines),
            Symbol(id: "forest1", type: .object, category: .rooms),
            Symbol(id: "forest2", type: .object, category: .rooms),
            Symbol(id: "forest3", type: .object, category: .rooms),
            Symbol(id: "knife", type: .object, category: .objects),
            Symbol(id: "path", type: .object, category: .rooms),
            Symbol(id: "sword", type: .object, category: .objects),
            Symbol(id: "thief", type: .object, category: .objects),
            Symbol(id: "thiefMelee", type: .bool, category: .routines),
            Symbol(id: "troll", type: .object, category: .objects),
            Symbol(id: "trollMelee", type: .bool, category: .routines),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("CONSTANT"))
    }

    func testAtom() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .atom("unexpected")
        ]).process()

        let expected = Symbol(
            id: "foo",
            code: "let foo: <Unknown> = unexpected",
            type: .unknown,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("foo", category: .constants), expected)
    }

    func testBool() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .bool(true)
        ]).process()

        let expected = Symbol(
            id: "foo",
            code: "let foo: Bool = true",
            type: .bool,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("foo", category: .constants), expected)
    }

    func testCommented() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("FOO"),
                .commented(.string("BAR"))
            ]).process()
        )
    }

    func testDecimal() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .decimal(42)
        ]).process()

        let expected = Symbol(
            id: "foo",
            code: "let foo: Int = 42",
            type: .int,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("foo", category: .constants), expected)
    }

    func testFormTable() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .form([
                .atom("TABLE"),
                .atom("FOREST-1"),
                .atom("FOREST-2"),
                .atom("FOREST-3"),
            ])
        ]).process()

        let expected = Symbol(
            id: "foo",
            code: """
                let foo: Table = Table(
                    .room(forest1),
                    .room(forest2),
                    .room(forest3)
                )
                """,
            type: .table,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("foo", category: .constants), expected)
    }

    func testFormPureLTable() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .form([
                .atom("LTABLE"),
                .list([
                    .atom("PURE")
                ]),
                .atom("FOREST-1"),
                .atom("FOREST-2"),
                .atom("FOREST-3"),
                .atom("PATH"),
                .atom("CLEARING"),
                .atom("FOREST-1"),
            ])
        ]).process()

        let expected = Symbol(
            id: "foo",
            code: """
                let foo: Table = Table(
                    .room(forest1),
                    .room(forest2),
                    .room(forest3),
                    .room(path),
                    .room(clearing),
                    .room(forest1),
                    flags: [.length, .pure]
                )
                """,
            type: .table,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("foo", category: .constants),
            expected
        )
    }

    func testFormNestedLTables() throws {
        let symbol = try factory.init([
            .atom("VILLAINS"),
            .form([
                .atom("LTABLE"),
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
                .form([
                    .atom("TABLE"),
                    .atom("CYCLOPS"),
                    .bool(false),
                    .decimal(0),
                    .decimal(0),
                    .atom("CYCLOPS-MELEE")
                ])
            ])
        ]).process()

        let expected = Symbol(
            id: "villains",
            code: """
                let villains: Table = Table(
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
                    )),
                    .table(Table(
                        .object(cyclops),
                        .bool(false),
                        .int(0),
                        .int(0),
                        .bool(cyclopsMelee)
                    )),
                    flags: [.length]
                )
                """,
            type: .table,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("villains", category: .constants),
            expected
        )
    }

    func testFormTableWithCommented() throws {
        let symbol = try factory.init([
            .atom("DEF1-RES"),
            .form([
                .atom("TABLE"),
                .atom("DEF1"),
                .decimal(0),
                .commented(.form([
                    .atom("REST"),
                    .global("DEF1"),
                    .decimal(2)
                ])),
                .decimal(0),
                .commented(.form([
                    .atom("REST"),
                    .global("DEF1"),
                    .decimal(4)
                ]))
            ])
        ]).process()

        let expected = Symbol(
            id: "def1Res",
            code: """
                let def1Res: Table = Table(
                    .table(def1),
                    .int(0),
                    // /* ["REST", "DEF1", "2"] */,
                    .int(0),
                    // /* ["REST", "DEF1", "4"] */
                )
                """,
            type: .table,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("def1Res", category: .constants),
            expected
        )
    }

    func testList() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .list([.string("BAR")])
        ]).process()

        let expected = Symbol(
            id: "foo",
            code: """
                let foo: [String] = ["BAR"]
                """,
            type: .array(.string),
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("foo", category: .constants),
            expected
        )
    }

    func testQuoted() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .quote(.string("BAR"))
        ]).process()

        let expected = Symbol(
            id: "foo",
            code: """
                let foo: String = "BAR"
                """,
            type: .string,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("foo", category: .constants),
            expected
        )
    }

    func testString() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .string("Forty Two!")
        ]).process()

        let expected = Symbol(

            id: "foo",
            code: """
                    let foo: String = "Forty Two!"
                    """,
            type: .string,
            category: .constants
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("foo", category: .constants),
            expected
        )
    }
}
