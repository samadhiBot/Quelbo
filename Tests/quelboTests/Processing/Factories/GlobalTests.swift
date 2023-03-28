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
            code: """
                /// The `foo` (FOO) Bool global.
                var foo = true
                """,
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
            code: """
                /// The `foo` (FOO) Bool global.
                var foo = false
                """,
            type: .booleanFalse,
            category: .globals,
            isCommittable: true,
            isMutable: true
        )

        XCTAssertNoDifference(symbol, .statement(foo))
        XCTAssertNoDifference(Game.findInstance("foo"), Instance(foo))
    }

    func testBoolMaybe() throws {
        process("""
            <GLOBAL AGAIN-DIR <>>

            <ROUTINE MINI-PARSER ("AUX" (DIR <>))
              <SET DIR ,AGAIN-DIR>
              <COND (.DIR
               <SETG PRSO .DIR>
               <SETG AGAIN-DIR .DIR>)
              (ELSE
               <SETG AGAIN-DIR <>>)>>
        """)

        XCTAssertNoDifference(
            Game.globals.find("againDir"),
            Statement(
                id: "againDir",
                code: """
                    /// The `againDir` (AGAIN-DIR) 􀎠Object? global.
                    var againDir: Object?
                    """,
                type: .object.optional,
                category: .globals,
                isCommittable: true,
                isMutable: true
            )
        )
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
            code: """
                /// The `foo` (FOO) 􀎠Int global.
                var foo = 42
                """,
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
                /// The `foo` (FOO) 􀎠􀁮Table global.
                var foo = Table(
                    .room("forest1"),
                    .room("forest2"),
                    .room("forest3")
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
                /// The `foo` (FOO) 􀎠􀁮Table global.
                var foo = Table(
                    .room("forest1"),
                    .room("forest2"),
                    .room("forest3"),
                    .room("path"),
                    .room("clearing"),
                    .room("forest1"),
                    flags: .length, .pure
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
                /// The `villains` (VILLAINS) 􀎠􀁮Table global.
                var villains = Table(
                    .table(
                        .object("troll"),
                        .object("sword"),
                        1,
                        0,
                        .table(Globals.trollMelee)
                    ),
                    .table(
                        .object("thief"),
                        .object("knife"),
                        1,
                        0,
                        .table(Globals.thiefMelee)
                    ),
                    .table(
                        .object("cyclops"),
                        false,
                        0,
                        0,
                        .table(Globals.cyclopsMelee)
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
            code: """
                /// The `def1Res` (DEF1-RES) 􀎠􀁮Table global.
                var def1Res = Table(.table(Globals.def1), 0, 0)
                """,
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
                /// The `foo` (FOO) 􀎠[String] global.
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
                /// The `foo` (FOO) 􀎠String global.
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
                code: """
                    /// The `againDir` (AGAIN-DIR) Bool global.
                    var againDir = false
                    """,
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
                code: """
                    /// The `againDir` (AGAIN-DIR) 􀎠Object? global.
                    var againDir: Object?
                    """,
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
                code: """
                    /// The `kitchenWindowFlag` (KITCHEN-WINDOW-FLAG) Bool global.
                    var kitchenWindowFlag = false
                    """,
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
                code: """
                    /// The `kitchenWindowFlag` (KITCHEN-WINDOW-FLAG) Bool global.
                    var kitchenWindowFlag = false
                    """,
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
            code: "p.isLessThan(Constants.lowDirection)",
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
        process("""
            <CONSTANT P-PSOFF 4> ;"Offset to first part of speech"

            <ROUTINE TEST-ROUTINE ("AUX" WRD)
              <BTST <GETB .WRD ,P-PSOFF> ,PS?OBJECT>>
        """)

        XCTAssertNoDifference(
            Game.routines.find("testRoutine"),
            Statement(
                id: "testRoutine",
                code: """
                    @discardableResult
                    /// The `testRoutine` (TEST-ROUTINE) routine.
                    func testRoutine() -> Int {
                        var wrd: Table?
                        return .bitwiseCompare(
                            try wrd.get(at: Constants.pPsoff),
                            PartsOfSpeech.object
                        )
                    }
                    """,
                type: .int.tableElement,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
