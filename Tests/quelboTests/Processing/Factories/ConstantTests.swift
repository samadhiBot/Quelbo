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
            .variable(id: "clearing", type: .object, category: .rooms),
            .variable(id: "cyclops", type: .object, category: .objects),
            .variable(id: "cyclopsMelee", type: .bool, category: .routines),
            .variable(id: "def1", type: .table, category: .globals),
            .variable(id: "forest1", type: .object, category: .rooms),
            .variable(id: "forest2", type: .object, category: .rooms),
            .variable(id: "forest3", type: .object, category: .rooms),
            .variable(id: "knife", type: .object, category: .objects),
            .variable(id: "path", type: .object, category: .rooms),
            .variable(id: "sword", type: .object, category: .objects),
            .variable(id: "thief", type: .object, category: .objects),
            .variable(id: "thiefMelee", type: .bool, category: .routines),
            .variable(id: "troll", type: .object, category: .objects),
            .variable(id: "trollMelee", type: .bool, category: .routines)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("CONSTANT"))
    }

    func testUnknownAtomThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("FOO"),
                .atom("unexpected")
            ], with: &localVariables).process()
        )
    }

    func testBoolTrue() throws {
        let symbol = try factory.init(
            [
            .atom("FOO"),
            .bool(true)
        ], with: &localVariables).process()

        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .bool,
            confidence: .booleanTrue,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "foo",
            code: "let foo: Bool = true",
            type: .bool,
            confidence: .booleanTrue,
            category: .constants
        ))
    }

    func testBoolFalse() throws {
        let symbol = try factory.init([
            .atom("PRSO"),
            .bool(false)
        ], with: &localVariables).process()

        XCTAssertNoDifference(Game.findGlobal("prso"), Variable(
            id: "prso",
            type: .bool,
            confidence: .booleanFalse,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "prso",
            code: "let prso: Bool = false",
            type: .bool,
            confidence: .booleanFalse,
            category: .constants
        ))
    }

    func testCommentedThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("FOO"),
                .commented(.string("BAR"))
            ], with: &localVariables).process()
        )
    }

    func testDecimal() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .decimal(42)
        ], with: &localVariables).process()

        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .int,
            confidence: .certain,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "foo",
            code: "let foo: Int = 42",
            type: .int,
            confidence: .certain,
            category: .constants
        ))
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .table,
            confidence: .certain,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "foo",
            code: """
                let foo: Table = Table(
                    .room(forest1),
                    .room(forest2),
                    .room(forest3)
                )
                """,
            type: .table,
            confidence: .certain,
            category: .constants
        ))
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .table,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "foo",
            code: """
                let foo: Table = Table(
                    flags: [.length, .pure],
                    .room(forest1),
                    .room(forest2),
                    .room(forest3),
                    .room(path),
                    .room(clearing),
                    .room(forest1)
                )
                """,
            type: .table,
            confidence: .certain,
            category: .constants
        ))
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(Game.findGlobal("villains"), Variable(
            id: "villains",
            type: .table,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "villains",
            code: """
                let villains: Table = Table(
                    flags: [.length],
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
                    ))
                )
                """,
            type: .table,
            confidence: .certain,
            category: .constants
        ))
    }

    func testFormNestedTableWithComments() throws {
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(Game.findGlobal("def1Res"), Variable(
            id: "def1Res",
            type: .table,
            category: .constants
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "def1Res",
            code: """
                let def1Res: Table = Table(
                    .table(def1),
                    .int(0),
                    // ["REST", "DEF1", "2"],
                    .int(0),
                    // ["REST", "DEF1", "4"]
                )
                """,
            type: .table,
            confidence: .certain,
            category: .constants
        ))
    }

    func testList() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .list([
                .string("BAR"),
                .string("BAT"),
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .array(.string),
            confidence: .certain,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "foo",
            code: """
                let foo: [String] = ["BAR", "BAT"]
                """,
            type: .array(.string),
            confidence: .certain,
            category: .constants
        ))
    }

    func testString() throws {
        let symbol = try factory.init([
            .atom("FOO"),
            .string("Forty Two!")
        ], with: &localVariables).process()

        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .string,
            confidence: .certain,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "foo",
            code: """
                let foo: String = "Forty Two!"
                """,
            type: .string,
            confidence: .certain,
            category: .constants
        ))
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(Game.findGlobal("square"), Variable(
            id: "square",
            type: .function([.int], .int),
            confidence: .certain,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "square",
            code: """
                let square: (Int) -> Int = { (x: Int) -> Int in
                    var x: Int = x
                    return x.multiply(x)
                }
                """,
            type: .function([.int], .int),
            confidence: .certain,
            category: .constants
        ))
    }

    func testWhenBooleanFalseSignifiesObjectPlaceholder() throws {
        _ = try factory.init([
            .atom("PRSO"),
            .bool(false)
        ], with: &localVariables).process()

        // `prso` is recorded as a boolean, but it's understood that `<>` might have been a
        // placeholder for another type (as noted in the meta property).
        XCTAssertNoDifference(Game.findGlobal("prso"), Variable(
            id: "prso",
            type: .bool,
            category: .constants
        ))

        // Move expects `prso` to be an object, not a boolean. This triggers an update of the
        // `prso` game symbol's type from boolean to object.
        let move = try Factories.Move([
            .global("PRSO"),
            .global("CLEARING")
        ], with: &localVariables).process()

        XCTAssertNoDifference(move, .statement(
            code: "prso.move(to: clearing)",
            type: .void,
            confidence: .void,
            returnable: .void
        ))

        // Inspecting the `prso` game symbol confirms that the type update took place.
        XCTAssertNoDifference(Game.findGlobal("prso"), Variable(
            id: "prso",
            type: .object,
            confidence: .certain,
            category: .constants,
            isMutable: true
        ))
    }

    func testWhenBooleanFalseSignifiesBooleanFalse() throws {
        _ = try factory.init([
            .atom("KITCHEN-WINDOW-FLAG"),
            .bool(false)
        ], with: &localVariables).process()

        // `kitchenWindowFlag` is recorded as a boolean, but it's understood that `<>` might have
        // been a placeholder for another type (as noted in the meta property).
        XCTAssertNoDifference(Game.findGlobal("kitchenWindowFlag"), Variable(
            id: "kitchenWindowFlag",
            type: .bool,
            category: .constants
        ))

        // Set has no type expectation, but interprets `T` as a boolean true value. Therefore
        // there's no need to overwrite the `kitchenWindowFlag` type.
        let set = try Factories.SetVariable([
            .atom("KITCHEN-WINDOW-FLAG"),
            .atom("T")
        ], with: &localVariables).process()

        XCTAssertNoDifference(set, .statement(
            code: "kitchenWindowFlag.set(to: true)",
            type: .bool,
            confidence: .booleanTrue,
            returnable: .implicit
        ))

        // Inspecting the `kitchenWindowFlag` game symbol confirms that the type remains boolean.
        XCTAssertNoDifference(Game.findGlobal("kitchenWindowFlag"), Variable(
            id: "kitchenWindowFlag",
            type: .bool,
            category: .constants
        ))
    }
}
