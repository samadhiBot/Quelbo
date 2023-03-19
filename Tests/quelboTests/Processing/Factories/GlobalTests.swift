//
//  GlobalTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/1/22.
//

import CustomDump
import Fizmo
import XCTest
@testable import quelbo

final class GlobalTests: QuelboTests {
    let factory = Factories.Global.self

    override func setUp() {
        super.setUp()

        process("""
            <CONSTANT MISSED 1> ;"attacker misses"

            <GLOBAL CYCLOPS-MELEE <TABLE (PURE) "Cyclops melee message">>
            <GLOBAL DEF1 <TABLE (PURE) MISSED MISSED MISSED MISSED>>
            <GLOBAL THIEF-MELEE <TABLE (PURE) "Thief melee message">>
            <GLOBAL TROLL-MELEE <TABLE (PURE) "Troll melee message">>
            <OBJECT CYCLOPS><OBJECT KNIFE><OBJECT SWORD><OBJECT THIEF><OBJECT TROLL>
            <ROOM CLEARING><ROOM FOREST1><ROOM FOREST2><ROOM FOREST3><ROOM PATH>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("GLOBAL", type: .mdl))
        AssertSameFactory(factory, Game.findFactory("SETG", type: .mdl))
    }

    func testBoolTrue() throws {
        let symbol = process("<GLOBAL FOO T>")

        let foo = Statement(
            id: "foo",
            code: "var foo = true",
            type: .booleanTrue,
            category: .globals,
            isCommittable: true,
            isMutable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findInstance("foo"), Instance(foo))
    }

    func testBoolFalse() throws {
        let symbol = process("<GLOBAL FOO <>>")

        let foo = Statement(
            id: "foo",
            code: "var foo = false",
            type: .booleanFalse,
            category: .globals,
            isCommittable: true,
            isMutable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findInstance("foo"), Instance(foo))
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
        let symbol = process("<GLOBAL FOO 42>")

        let foo = Statement(
            id: "foo",
            code: "var foo = 42",
            type: .int,
            category: .globals,
            isCommittable: true,
            isMutable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findInstance("foo"), Instance(foo))
    }

    func testFormTable() throws {
        let symbol = process("<GLOBAL FOO <TABLE FOREST-1 FOREST-2 FOREST-3>>")

        let foo = Statement(
            id: "foo",
            code: """
                var foo = Table(
                    .room("Rooms.forest1"),
                    .room("Rooms.forest2"),
                    .room("Rooms.forest3")
                )
                """,
            type: .table.root,
            category: .globals,
            isCommittable: true,
            isMutable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findInstance("foo"), Instance(foo))
    }

    func testFormPureLTable() throws {
        let symbol = process("""
            <GLOBAL FOO <LTABLE (PURE) FOREST-1 FOREST-2 FOREST-3 PATH CLEARING FOREST-1>>
        """)

        let foo = Statement(
            id: "foo",
            code: """
                let foo = Table(
                    .room("Rooms.forest1"),
                    .room("Rooms.forest2"),
                    .room("Rooms.forest3"),
                    .room("Rooms.path"),
                    .room("Rooms.clearing"),
                    .room("Rooms.forest1"),
                    flags: .length
                )
                """,
            type: .table.root,
            category: .constants,
            isCommittable: true,
            isMutable: false
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findInstance("foo"), Instance(foo))
    }

    func testFormNestedLTables() throws {
        let symbol = process("""
            <GLOBAL VILLAINS
                <LTABLE <TABLE TROLL SWORD 1 0 TROLL-MELEE>
                    <TABLE THIEF KNIFE 1 0 THIEF-MELEE>
                    <TABLE CYCLOPS <> 0 0 CYCLOPS-MELEE>>>
        """)

        let villains = Statement(
            id: "villains",
            code: """
                var villains = Table(
                    .table(
                        .object("Objects.troll"),
                        .object("Objects.sword"),
                        .int(1),
                        .int(0),
                        .table(Constants.trollMelee)
                    ),
                    .table(
                        .object("Objects.thief"),
                        .object("Objects.knife"),
                        .int(1),
                        .int(0),
                        .table(Constants.thiefMelee)
                    ),
                    .table(
                        .object("Objects.cyclops"),
                        .bool(false),
                        .int(0),
                        .int(0),
                        .table(Constants.cyclopsMelee)
                    ),
                    flags: .length
                )
                """,
            type: .table.root,
            category: .globals,
            isCommittable: true,
            isMutable: true
        )

        XCTAssertNoDifference(symbol, .statement(villains))
        XCTAssertNoDifference(Game.findInstance("villains"), Instance(villains))
    }

    func testFormNestedTableWithComments() throws {
        let symbol = process("""
            <GLOBAL DEF1-RES
                <TABLE DEF1
                       0 ;<REST ,DEF1 2>
                       0 ;<REST ,DEF1 4>>>
        """)

        let def1Res = Statement(
            id: "def1Res",
            code: "var def1Res = Table(.table(Constants.def1), .int(0), .int(0))",
            type: .table.root,
            category: .globals,
            isCommittable: true,
            isMutable: true
        )

        XCTAssertNoDifference(symbol, .statement(def1Res))
        XCTAssertNoDifference(Game.findInstance("def1Res"), Instance(def1Res))
    }

    func testList() throws {
        let symbol = process("""
            <GLOBAL FOO ("BAR" "BAT")>
        """)

        let foo = Statement(
            id: "foo",
            code: """
                var foo = ["BAR", "BAT"]
                """,
            type: .string.array,
            category: .globals,
            isCommittable: true,
            isMutable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findInstance("foo"), Instance(foo))
    }

    func testString() throws {
        let symbol = process("""
            <GLOBAL FOO "Forty Two!">
        """)

        let foo = Statement(
            id: "foo",
            code: """
                var foo = "Forty Two!"
                """,
            type: .string,
            category: .globals,
            isCommittable: true,
            isMutable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findInstance("foo"), Instance(foo))
    }

    func testWhenBooleanFalseSignifiesObjectPlaceholder() throws {
        process("""
            <GLOBAL AGAIN-DIR <>>
        """)

        XCTAssertNoDifference(
            Game.findInstance("againDir"),
            Instance(Statement(
                id: "againDir",
                code: "var againDir = false",
                type: .booleanFalse,
                category: .globals,
                isCommittable: true,
                isMutable: true
            ))
        )

        process("""
            <ROUTINE PARSER ("AUX" (DIR <>))
                <SETG PRSO .DIR>
                <SETG AGAIN-DIR .DIR>>
        """)

        XCTAssertNoDifference(
            Game.findInstance("againDir"),
            Instance(Statement(
                id: "againDir",
                code: "var againDir: Object?",
                type: .object.optional,
                category: .globals,
                isCommittable: true,
                isMutable: true
            ))
        )
    }

    func testWhenBooleanFalseSignifiesBooleanFalse() throws {
        process("<GLOBAL KITCHEN-WINDOW-FLAG <>>")

        // `kitchenWindowFlag` is recorded as a boolean, but it's understood that `<>` might have
        // been a placeholder for another type (as noted in the meta property).
        XCTAssertNoDifference(
            Game.findInstance("kitchenWindowFlag"),
            Instance(Statement(
                id: "kitchenWindowFlag",
                code: "var kitchenWindowFlag = false",
                type: .booleanFalse,
                category: .globals,
                isCommittable: true,
                isMutable: true
            ))
        )

        // Set has no type expectation, but interprets `T` as a boolean true value. Therefore
        // there's no need to overwrite the `kitchenWindowFlag` type.
        process("""
            <ROUTINE KITCHEN-WINDOW-F ()
                <SETG KITCHEN-WINDOW-FLAG T>>
        """)

        XCTAssertNoDifference(
            Game.routines.find("kitchenWindowFunc"),
            Statement(
                id: "kitchenWindowFunc",
                code: """
                    @discardableResult
                    /// The `kitchenWindowFunc` (KITCHEN-WINDOW-F) routine.
                    func kitchenWindowFunc() -> Bool {
                        return Globals.kitchenWindowFlag.set(to: true)
                    }
                    """,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )

        // Inspecting the `kitchenWindowFlag` game symbol confirms that the type remains boolean.
        XCTAssertNoDifference(
            Game.findInstance("kitchenWindowFlag"),
            Instance(Statement(
                id: "kitchenWindowFlag",
                code: "var kitchenWindowFlag = false",
                type: .booleanTrue,
                category: .globals,
                isCommittable: true,
                isMutable: true
            ))
        )
    }
}

// MARK: - Reserved globals

extension GlobalTests {
    func testActions() throws {
        let symbol = process(
            "<GET ,ACTIONS .A>",
            type: .zCode,
            with: [
                Statement(id: "a", type: .int)
            ]
        )

        XCTAssertNoDifference(symbol, .statement(
            code: "try Globals.actions.get(at: a)",
            type: .someTableElement,
            isThrowing: true
        ))
    }

    func testIsActFind() throws {
        let symbol = process(
            "<EQUAL? .VERB ,ACT?FIND>",
            type: .zCode,
            with: [
                Statement(id: "verb", type: .verb)
            ]
        )

        XCTAssertNoDifference(symbol, .statement(
            code: "verb.equals(Verb.find.action)",
            type: .bool
        ))
    }

    func testLowDirection() throws {
        let symbol = process(
            "<L? .P ,LOW-DIRECTION>",
            type: .zCode,
            with: [
                Statement(id: "p", type: .int)
            ]
        )

        XCTAssertNoDifference(symbol, .statement(
            code: "p.isLessThan(lowDirection)",
            type: .bool
        ))
    }

    func testNullFunc() throws {
        XCTAssertNoDifference(
            Game.routines.find("nullFunc"),
            Statement(
                id: "nullFunc",
                code: """
                    @discardableResult
                    /// The `nullFunc` (NULL-F) routine.
                    func nullFunc(a1: Any? = nil, a2: Any? = nil) -> Bool {
                        false
                    }
                    """,
                type: .bool,
                category: .routines
            )
        )
    }

    func testPartsOfSpeech() throws {
        let symbol = process(
            "<L? .P ,LOW-DIRECTION>",
            type: .zCode,
            with: [
                Statement(id: "p", type: .int)
            ]
        )

        XCTAssertNoDifference(symbol, .statement(
            code: "p.isLessThan(lowDirection)",
            type: .bool
        ))
    }

}
