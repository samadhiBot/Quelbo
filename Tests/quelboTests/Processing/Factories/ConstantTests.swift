//
//  ConstantTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/22.
//

import CustomDump
import Fizmo
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
        let symbol = process("<CONSTANT FOO T>")

        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .booleanTrue,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "foo",
            code: "let foo: Bool = true",
            type: .booleanTrue,
            category: .constants,
            isCommittable: true
        ))
    }

    func testBoolFalse() throws {
        let symbol = process("<CONSTANT FOO <>>")

        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .booleanFalse,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "foo",
            code: "let foo: Bool = false",
            type: .booleanFalse,
            category: .constants,
            isCommittable: true
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
        let symbol = process("<CONSTANT FOO 42>")

        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .int,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "foo",
            code: "let foo: Int = 42",
            type: .int,
            category: .constants,
            isCommittable: true
        ))
    }

    func testFormTable() throws {
        let symbol = process("<CONSTANT FOO <TABLE FOREST-1 FOREST-2 FOREST-3>>")

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
                    .room(forest1),
                    .room(forest2),
                    .room(forest3)
                )
                """,
            type: .table,
            category: .constants,
            isCommittable: true
        ))
    }

    func testFormPureLTable() throws {
        let symbol = process("""
            <CONSTANT FOO <LTABLE (PURE) FOREST-1 FOREST-2 FOREST-3 PATH CLEARING FOREST-1>>
        """)

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
            category: .constants,
            isCommittable: true
        ))
    }

    func testFormNestedLTables() throws {
        let symbol = process("""
            <CONSTANT VILLAINS
                <LTABLE <TABLE TROLL SWORD 1 0 TROLL-MELEE>
                    <TABLE THIEF KNIFE 1 0 THIEF-MELEE>
                    <TABLE CYCLOPS <> 0 0 CYCLOPS-MELEE>>>
        """)

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
            category: .constants,
            isCommittable: true
        ))
    }

    func testFormNestedTableWithComments() throws {
        let symbol = process("""
            <CONSTANT DEF1-RES
                <TABLE DEF1
                       0 ;<REST ,DEF1 2>
                       0 ;<REST ,DEF1 4>>>
        """)

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
            category: .constants,
            isCommittable: true
        ))
    }

    func testList() throws {
        let symbol = process("""
            <CONSTANT FOO ("BAR" "BAT")>
        """)

        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .array(.string),
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "foo",
            code: """
                let foo: [String] = ["BAR", "BAT"]
                """,
            type: .array(.string),
            category: .constants,
            isCommittable: true
        ))
    }

    func testString() throws {
        let symbol = process("""
            <CONSTANT FOO "Forty Two!">
        """)

        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .string,
            category: .constants,
            isMutable: false
        ))

        XCTAssertNoDifference(symbol, .statement(
            id: "foo",
            code: """
                let foo: String = "Forty Two!"
                """,
            type: .string,
            category: .constants,
            isCommittable: true
        ))
    }

    func testWhenBooleanFalseSignifiesObjectPlaceholder() throws {
        process("<CONSTANT FOO <>>")

        // `prso` is recorded as a boolean, but it's understood that `<>` might have been a
        // placeholder for another type (as noted in the meta property).
        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .booleanFalse,
            category: .constants
        ))

        // Move expects `foo` to be an object, not a boolean. This triggers an update of the
        // `foo` game symbol's type from boolean to object.
        let move = try Factories.Move([
            .global("FOO"),
            .global("CLEARING")
        ], with: &localVariables).process()

        XCTAssertNoDifference(move, .statement(
            code: "foo.move(to: clearing)",
            type: .void
        ))

        // Inspecting the `foo` game symbol confirms that the type update took place.
        XCTAssertNoDifference(Game.findGlobal("foo"), Variable(
            id: "foo",
            type: .object,
            category: .constants,
            isMutable: true
        ))
    }

    func testWhenBooleanFalseSignifiesBooleanFalse() throws {
        process("<CONSTANT KITCHEN-WINDOW-FLAG <>>")

        // `kitchenWindowFlag` is recorded as a boolean, but it's understood that `<>` might have
        // been a placeholder for another type (as noted in the meta property).
        XCTAssertNoDifference(Game.findGlobal("kitchenWindowFlag"), Variable(
            id: "kitchenWindowFlag",
            type: .booleanFalse,
            category: .constants,
            isMutable: false
        ))

        // Set has no type expectation, but interprets `T` as a boolean true value. Therefore
        // there's no need to overwrite the `kitchenWindowFlag` type.
        let set = try Factories.SetVariable([
            .atom("KITCHEN-WINDOW-FLAG"),
            .atom("T")
        ], with: &localVariables).process()

        XCTAssertNoDifference(set, .statement(
            code: "kitchenWindowFlag.set(to: true)",
            type: .booleanTrue
        ))

        // Inspecting the `kitchenWindowFlag` game symbol confirms that the type remains boolean.
        XCTAssertNoDifference(Game.findGlobal("kitchenWindowFlag"), Variable(
            id: "kitchenWindowFlag",
            type: .booleanTrue,
            category: .constants,
            isMutable: false
        ))
    }
}
