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

        try! Game.commit(
            Symbol("clearing", type: .object, category: .rooms),
            Symbol("cyclops", type: .object, category: .objects),
            Symbol("cyclopsMelee", type: .bool, category: .routines),
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
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("CONSTANT"))
    }

    func testAtom() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("FOO"),
                .atom("unexpected")
            ]).process()
        )
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
                    let foo: [ZilElement] = [
                        .room(forest1),
                        .room(forest2),
                        .room(forest3),
                    ]
                    """,
            type: .array(.zilElement),
            category: .constants,
            children: [
                Symbol(id: "forest1", code: ".room(forest1)", type: .zilElement, category: .rooms),
                Symbol(id: "forest2", code: ".room(forest2)", type: .zilElement, category: .rooms),
                Symbol(id: "forest3", code: ".room(forest3)", type: .zilElement, category: .rooms),
            ]
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
                let foo: [ZilElement] = [
                    .room(forest1),
                    .room(forest2),
                    .room(forest3),
                    .room(path),
                    .room(clearing),
                    .room(forest1),
                ]
                """,
            type: .array(.zilElement),
            category: .constants,
            children: [
                Symbol(id: "forest1", code: ".room(forest1)", type: .zilElement, category: .rooms),
                Symbol(id: "forest2", code: ".room(forest2)", type: .zilElement, category: .rooms),
                Symbol(id: "forest3", code: ".room(forest3)", type: .zilElement, category: .rooms),
                Symbol(id: "path", code: ".room(path)", type: .zilElement, category: .rooms),
                Symbol(id: "clearing", code: ".room(clearing)", type: .zilElement, category: .rooms),
                Symbol(id: "forest1", code: ".room(forest1)", type: .zilElement, category: .rooms),
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("foo", category: .constants), expected)
    }

//    func testFormNestedLTables() throws {
//        let symbol = try factory.init([
//            .atom("VILLAINS"),
//            .form([
//                .atom("LTABLE"),
//                .form([
//                    .atom("TABLE"),
//                    .atom("TROLL"),
//                    .atom("SWORD"),
//                    .decimal(1),
//                    .decimal(0),
//                    .atom("TROLL-MELEE")
//                ]),
//                .form([
//                    .atom("TABLE"),
//                    .atom("THIEF"),
//                    .atom("KNIFE"),
//                    .decimal(1),
//                    .decimal(0),
//                    .atom("THIEF-MELEE")
//                ]),
//                .form([
//                    .atom("TABLE"),
//                    .atom("CYCLOPS"),
//                    .bool(false),
//                    .decimal(0),
//                    .decimal(0),
//                    .atom("CYCLOPS-MELEE")
//                ])
//            ])
//        ]).process()
//
//        let expected = Symbol(
//            id: "villains",
//            code: """
//                let villains: [ZilElement] = [
//                    .table([
//                        .atom("troll"),
//                        .atom("sword"),
//                        .decimal(1),
//                        .decimal(0),
//                        .atom("trollMelee"),
//                    ]),
//                    .table([
//                        .atom("thief"),
//                        .atom("knife"),
//                        .decimal(1),
//                        .decimal(0),
//                        .atom("thiefMelee"),
//                    ]),
//                    .table([
//                        .atom("cyclops"),
//                        .bool(false),
//                        .decimal(0),
//                        .decimal(0),
//                        .atom("cyclopsMelee"),
//                    ]),
//                ]
//                """,
//            type: .array(.zilElement),
//            category: .constants,
//            children: [
//                Symbol(
//                    """
//                    .table([
//                        .atom("troll"),
//                        .atom("sword"),
//                        .decimal(1),
//                        .decimal(0),
//                        .atom("trollMelee"),
//                    ])
//                    """,
//                    type: .array(.zilElement),
//                    category: nil,
//                    children: [
//                        Symbol(
//                            id: ".atom(\"troll\")",
//                            code: ".atom(\"troll\")",
//                            type: .string,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".atom(\"sword\")",
//                            code: ".atom(\"sword\")",
//                            type: .string,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".decimal(1)",
//                            code: ".decimal(1)",
//                            type: .int,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".decimal(0)",
//                            code: ".decimal(0)",
//                            type: .int,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".atom(\"trollMelee\")",
//                            code: ".atom(\"trollMelee\")",
//                            type: .string,
//                            category: nil,
//                            children: []
//                        )
//                    ]
//                ),
//                Symbol(
//                    """
//                    .table([
//                        .atom("thief"),
//                        .atom("knife"),
//                        .decimal(1),
//                        .decimal(0),
//                        .atom("thiefMelee"),
//                    ])
//                    """,
//                    type: .array(.zilElement),
//                    category: nil,
//                    children: [
//                        Symbol(
//                            id: ".atom(\"thief\")",
//                            code: ".atom(\"thief\")",
//                            type: .string,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".atom(\"knife\")",
//                            code: ".atom(\"knife\")",
//                            type: .string,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".decimal(1)",
//                            code: ".decimal(1)",
//                            type: .int,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".decimal(0)",
//                            code: ".decimal(0)",
//                            type: .int,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".atom(\"thiefMelee\")",
//                            code: ".atom(\"thiefMelee\")",
//                            type: .string,
//                            category: nil,
//                            children: []
//                        )
//                    ]
//                ),
//                Symbol(
//                    """
//                    .table([
//                        .atom("cyclops"),
//                        .bool(false),
//                        .decimal(0),
//                        .decimal(0),
//                        .atom("cyclopsMelee"),
//                    ])
//                    """,
//                    type: .array(.zilElement),
//                    category: nil,
//                    children: [
//                        Symbol(
//                            id: ".atom(\"cyclops\")",
//                            code: ".atom(\"cyclops\")",
//                            type: .string,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".bool(false)",
//                            code: ".bool(false)",
//                            type: .bool,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".decimal(0)",
//                            code: ".decimal(0)",
//                            type: .int,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".decimal(0)",
//                            code: ".decimal(0)",
//                            type: .int,
//                            category: nil,
//                            children: []
//                        ),
//                        Symbol(
//                            id: ".atom(\"cyclopsMelee\")",
//                            code: ".atom(\"cyclopsMelee\")",
//                            type: .string,
//                            category: nil,
//                            children: []
//                        )
//                    ]
//                )
//            ]
//        )
//
//        XCTAssertNoDifference(symbol, expected)
//        XCTAssertNoDifference(try Game.find("villains", category: .constants), expected)
//    }

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
                    let def1Res: [ZilElement] = [
                        .table(def1),
                        .int(0),
                        // /* ["REST", "DEF1", "2"] */,
                        .int(0),
                        // /* ["REST", "DEF1", "4"] */,
                    ]
                    """,
            type: .array(.zilElement),
            category: .constants,
            children: [
                Symbol(id: "def1", code: ".table(def1)", type: .zilElement),
                Symbol(id: "0", code: ".int(0)", type: .zilElement, meta: [.isLiteral]),
                Symbol(id: "/* [\"REST\", \"DEF1\", \"2\"] */", code: "// /* [\"REST\", \"DEF1\", \"2\"] */", type: .zilElement),
                Symbol(id: "0", code: ".int(0)", type: .zilElement, meta: [.isLiteral]),
                Symbol(id: "/* [\"REST\", \"DEF1\", \"4\"] */", code: "// /* [\"REST\", \"DEF1\", \"4\"] */", type: .zilElement),
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("def1Res", category: .constants), expected)
    }

    func testList() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("FOO"),
                .list([.string("BAR")])
            ]).process()
        )
    }

    func testQuoted() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("FOO"),
                .quote(.string("BAR"))
            ]).process()
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
        XCTAssertNoDifference(try Game.find("foo", category: .constants), expected)
    }
}
