//
//  GlobalTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GlobalTests: QuelboTests {
    let factory = Factories.Global.self

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
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("GLOBAL"))
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("SETG"))
    }

    func testAtom() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .atom("unexpected")
        ]).process()

        let expected = Symbol(
            id: "foo",
            code: "var foo: <Unknown> = unexpected",
            category: .globals,
            children: [
                Symbol("unexpected")
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("foo", category: .globals), expected)
    }

    func testBoolTrue() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .bool(true)
        ]).process()

        let expected = Symbol(
            id: "foo",
            code: "var foo: Bool = true",
            type: .bool,
            category: .globals,
            children: [
                .trueSymbol
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("foo"), expected)
    }

    func testBoolFalseEvaluatesToUnknown() throws {
        let symbol = try factory.init([
            .atom("PRSO"),
            .bool(false)
        ]).process()

        let expected = Symbol(
            id: "prso",
            code: "var prso: Bool = false",
            type: .bool,
            category: .globals,
            children: [
                .falseSymbol
            ],
            meta: [.maybeEmptyValue]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("prso"), expected)
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
            code: "var foo: Int = 42",
            type: .int,
            category: .globals,
            children: [
                Symbol("42", type: .int, meta: [.isLiteral])
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("foo"), expected)
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
                    var foo: Table = Table(
                        .room(forest1),
                        .room(forest2),
                        .room(forest3)
                    )
                    """,
            type: .table,
            category: .globals,
            children: [
                Symbol(
                    """
                        Table(
                            .room(forest1),
                            .room(forest2),
                            .room(forest3)
                        )
                        """,
                    type: .table,
                    children: [
                        Symbol(
                            id: "forest1",
                            code: ".room(forest1)",
                            type: .zilElement,
                            category: .rooms
                        ),
                        Symbol(
                            id: "forest2",
                            code: ".room(forest2)",
                            type: .zilElement,
                            category: .rooms
                        ),
                        Symbol(
                            id: "forest3",
                            code: ".room(forest3)",
                            type: .zilElement,
                            category: .rooms
                        )
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("foo"), expected)
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

        XCTAssertNoDifference(symbol.ignoringChildren, expected)
        XCTAssertNoDifference(
            try Game.find("foo", category: .constants).ignoringChildren,
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
                var villains: Table = Table(
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
            category: .globals
        )

        XCTAssertNoDifference(symbol.ignoringChildren, expected)
        XCTAssertNoDifference(
            try Game.find("villains", category: .globals).ignoringChildren,
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
                var def1Res: Table = Table(
                    .table(def1),
                    .int(0),
                    // /* ["REST", "DEF1", "2"] */,
                    .int(0),
                    // /* ["REST", "DEF1", "4"] */
                )
                """,
            type: .table,
            category: .globals
        )

        XCTAssertNoDifference(symbol.ignoringChildren, expected)
        XCTAssertNoDifference(
            try Game.find("def1Res", category: .globals).ignoringChildren,
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
                var foo: [String] = ["BAR"]
                """,
            type: .array(.string),
            category: .globals
        )

        XCTAssertNoDifference(symbol.ignoringChildren, expected)
        XCTAssertNoDifference(
            try Game.find("foo", category: .globals).ignoringChildren,
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
                var foo: String = "BAR"
                """,
            type: .string,
            category: .globals
        )

        XCTAssertNoDifference(symbol.ignoringChildren, expected)
        XCTAssertNoDifference(
            try Game.find("foo", category: .globals).ignoringChildren,
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
                var foo: String = "Forty Two!"
                """,
            type: .string,
            category: .globals
        )

        XCTAssertNoDifference(symbol.ignoringChildren, expected)
        XCTAssertNoDifference(
            try Game.find("foo", category: .globals).ignoringChildren,
            expected
        )
    }

    func testFunction() throws {
        let symbol = try factory.init([
            .atom("SQUARE"),
            .form([
                .atom("FUNCTION"),
                .list([
                    .atom("X")
                ]),
                .form([
                    .atom("*"),
                    .local("X"),
                    .local("X")
                ])
            ])
        ]).process()

        let expected = Symbol(
            id: "square",
            code: """
                let square: (Int) -> Int = { (x: Int) -> Int in
                    var x = x
                    return x.multiply(x)
                }
                """,
            type: .int,
            category: .constants
        )

        XCTAssertNoDifference(symbol.ignoringChildren, expected)
        XCTAssertNoDifference(
            try Game.find("square").ignoringChildren,
            expected
        )
    }

    func testWhenBooleanFalseSignifiesObjectPlaceholder() throws {
        _ = try factory.init([
            .atom("PRSO"),
            .bool(false)
        ]).process()

        // `prso` is recorded as a boolean, but it's understood that `<>` might have been a
        // placeholder for another type (as noted in the meta property).
        XCTAssertNoDifference(try Game.find("prso"), Symbol(
            id: "prso",
            code: "var prso: Bool = false",
            type: .bool,
            category: .globals,
            children: [.falseSymbol],
            meta: [.maybeEmptyValue]
        ))

        // Move expects `prso` to be an object, not a boolean. This triggers an overwrite of the
        // `prso` game symbol's type from boolean to object.
        let move = try Factories.Move.init([
            .global("PRSO"),
            .global("CLEARING")
        ]).process()

        XCTAssertNoDifference(move, Symbol(
            "prso.move(to: clearing)",
            type: .void,
            children: [
                Symbol(
                    "prso",
                    type: .object,
                    category: .globals,
                    children: [
                        .falseSymbol
                    ],
                    meta: [.maybeEmptyValue]
                ),
                Symbol("clearing", type: .object, category: .rooms),
            ]
        ))

        // Inspecting the `prso` game symbol confirms that the type overwrite took place.
        XCTAssertNoDifference(try Game.find("prso"), Symbol(
            id: "prso",
            code: "var prso: Object = .nullObject",
            type: .object,
            category: .globals,
            children: [.falseSymbol],
            meta: [.maybeEmptyValue]
        ))
    }

    func testWhenBooleanFalseSignifiesBooleanFalse() throws {
        _ = try factory.init([
            .atom("KITCHEN-WINDOW-FLAG"),
            .bool(false)
        ]).process()

        // `kitchenWindowFlag` is recorded as a boolean, but it's understood that `<>` might have
        // been a placeholder for another type (as noted in the meta property).
        XCTAssertNoDifference(try Game.find("kitchenWindowFlag"), Symbol(
            id: "kitchenWindowFlag",
            code: "var kitchenWindowFlag: Bool = false",
            type: .bool,
            category: .globals,
            children: [.falseSymbol],
            meta: [.maybeEmptyValue]
        ))

        // Set has no type expectation, but interprets `T` as a boolean true value. Therefore
        // there's no need to overwrite the `kitchenWindowFlag` type.
        let set = try Factories.Set([
            .atom("KITCHEN-WINDOW-FLAG"),
            .atom("T")
        ]).process()

        XCTAssertNoDifference(set.ignoringChildren, Symbol(
            "kitchenWindowFlag.set(to: true)",
            type: .bool
        ))

        // Inspecting the `kitchenWindowFlag` game symbol confirms that the type remains boolean.
        XCTAssertNoDifference(try Game.find("kitchenWindowFlag"), Symbol(
            id: "kitchenWindowFlag",
            code: "var kitchenWindowFlag: Bool = false",
            type: .bool,
            category: .globals,
            children: [.falseSymbol],
            meta: [.maybeEmptyValue]
        ))
    }
}
