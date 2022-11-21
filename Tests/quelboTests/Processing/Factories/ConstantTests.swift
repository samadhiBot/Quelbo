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

        process("""
            <GLOBAL CYCLOPS-MELEE <TABLE (PURE) "Cyclops melee message">>
            <GLOBAL DEF1 <TABLE (PURE) MISSED MISSED MISSED MISSED>>
            <GLOBAL THIEF-MELEE <TABLE (PURE) "Thief melee message">>
            <GLOBAL TROLL-MELEE <TABLE (PURE) "Troll melee message">>
            <OBJECT CYCLOPS><OBJECT KNIFE><OBJECT SWORD><OBJECT THIEF><OBJECT TROLL>
            <ROOM CLEARING><ROOM FOREST1><ROOM FOREST2><ROOM FOREST3><ROOM PATH>
        """)
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

        let foo = Statement(
            id: "foo",
            code: "let foo: Bool = true",
            type: .booleanTrue,
            category: .constants,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findGlobal("foo"), Instance(foo))
    }

    func testBoolFalse() throws {
        let symbol = process("<CONSTANT FOO <>>")

        let foo = Statement(
            id: "foo",
            code: "let foo: Bool = false",
            type: .booleanFalse,
            category: .constants,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findGlobal("foo"), Instance(foo))
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

        let foo = Statement(
            id: "foo",
            code: "let foo: Int = 42",
            type: .int,
            category: .constants,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findGlobal("foo"), Instance(foo))
    }

    func testFormTable() throws {
        let symbol = process("<CONSTANT FOO <TABLE FOREST-1 FOREST-2 FOREST-3>>")

        let foo = Statement(
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
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findGlobal("foo"), Instance(foo))
    }

    func testFormPureLTable() throws {
        let symbol = process("""
            <CONSTANT FOO <LTABLE (PURE) FOREST-1 FOREST-2 FOREST-3 PATH CLEARING FOREST-1>>
        """)

        let foo = Statement(
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
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findGlobal("foo"), Instance(foo))
    }

    func testFormNestedLTables() throws {
        let symbol = process("""
            <CONSTANT VILLAINS
                <LTABLE <TABLE TROLL SWORD 1 0 TROLL-MELEE>
                    <TABLE THIEF KNIFE 1 0 THIEF-MELEE>
                    <TABLE CYCLOPS <> 0 0 CYCLOPS-MELEE>>>
        """)

        let villains = Statement(
            id: "villains",
            code: """
                let villains: Table = Table(
                    flags: [.length],
                    .table(
                        .object(troll),
                        .object(sword),
                        .int(1),
                        .int(0),
                        .table(trollMelee)
                    ),
                    .table(
                        .object(thief),
                        .object(knife),
                        .int(1),
                        .int(0),
                        .table(thiefMelee)
                    ),
                    .table(
                        .object(cyclops),
                        .bool(false),
                        .int(0),
                        .int(0),
                        .table(cyclopsMelee)
                    )
                )
                """,
            type: .table,
            category: .constants,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(villains))
        XCTAssertNoDifference(Game.findGlobal("villains"), Instance(villains))
    }

    func testFormNestedTableWithComments() throws {
        let symbol = process("""
            <CONSTANT DEF1-RES
                <TABLE DEF1
                       0 ;<REST ,DEF1 2>
                       0 ;<REST ,DEF1 4>>>
        """)

        let def1Res = Statement(
            id: "def1Res",
            code: """
                let def1Res: Table = Table(
                    .table(def1),
                    .int(0),
                    // <REST ,DEF1 2>,
                    .int(0),
                    // <REST ,DEF1 4>
                )
                """,
            type: .table,
            category: .constants,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(def1Res))
        XCTAssertNoDifference(Game.findGlobal("def1Res"), Instance(def1Res))
    }

    func testList() throws {
        let symbol = process("""
            <CONSTANT FOO ("BAR" "BAT")>
        """)

        let foo = Statement(
            id: "foo",
            code: """
                let foo: [String] = ["BAR", "BAT"]
                """,
            type: .string.array,
            category: .constants,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findGlobal("foo"), Instance(foo))
    }

    func testString() throws {
        let symbol = process("""
            <CONSTANT FOO "Forty Two!">
        """)

        let foo = Statement(
            id: "foo",
            code: """
                let foo: String = "Forty Two!"
                """,
            type: .string,
            category: .constants,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findGlobal("foo"), Instance(foo))
    }
}
