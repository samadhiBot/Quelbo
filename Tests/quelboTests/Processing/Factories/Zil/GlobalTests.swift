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
            Symbol(id: "trollMelee", type: .bool, category: .routines)
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
            category: .globals
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
            category: .globals
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
            category: .globals
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
            category: .globals
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

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("villains", category: .globals),
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

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("def1Res", category: .globals),
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

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("foo", category: .globals),
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

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("foo", category: .globals),
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

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("foo", category: .globals),
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

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(
            try Game.find("square"),
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
            type: .void
        ))

        // Inspecting the `prso` game symbol confirms that the type overwrite took place.
        XCTAssertNoDifference(try Game.find("prso"), Symbol(
            id: "prso",
            code: "var prso: Object? = nil",
            type: .optional(.object),
            category: .globals,
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
            meta: [.maybeEmptyValue]
        ))

        // Set has no type expectation, but interprets `T` as a boolean true value. Therefore
        // there's no need to overwrite the `kitchenWindowFlag` type.
        let set = try Factories.SetVariable([
            .atom("KITCHEN-WINDOW-FLAG"),
            .atom("T")
        ]).process()

        XCTAssertNoDifference(set, Symbol(
            "kitchenWindowFlag.set(to: true)",
            type: .bool
        ))

        // Inspecting the `kitchenWindowFlag` game symbol confirms that the type remains boolean.
        XCTAssertNoDifference(try Game.find("kitchenWindowFlag"), Symbol(
            id: "kitchenWindowFlag",
            code: "var kitchenWindowFlag: Bool = false",
            type: .bool,
            category: .globals,
            meta: [.maybeEmptyValue]
        ))
    }
}
