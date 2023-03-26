//
//  RoutineTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/11/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RoutineTests: QuelboTests {
    let factory = Factories.Routine.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .statement(
                id: "isLit",
                code: "",
                type: .bool,
                category: .routines,
                isCommittable: true
            ),
            .statement(singSymbol),
            .variable(id: "axe", type: .object, category: .objects),
            .variable(id: "here", type: .object, category: .rooms),
            .variable(id: "knife", type: .object, category: .objects),
            .variable(id: "mLook", type: .int, category: .globals),
            .variable(id: "rustyKnife", type: .object, category: .objects),
            .variable(id: "stiletto", type: .object, category: .objects),
            .variable(id: "sword", type: .object, category: .objects),
            .variable(id: "wonFlag", type: .bool, category: .flags),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ROUTINE"))
    }

    func testProcessZeroParamsZeroExpressions() throws {
        let symbol = process("""
            <ROUTINE BAG-OF-COINS-F ()
                 ;"<STUPID-CONTAINER ,BAG-OF-COINS 'coins'>"
            >
        """)

        let expected = Statement(
            id: "bagOfCoinsFunc",
            code: """
                /// The `bagOfCoinsFunc` (BAG-OF-COINS-F) routine.
                func bagOfCoinsFunc() {

                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("bagOfCoinsFunc"), expected)
    }

    func testProcessZeroParamsOneExpression() throws {
        let symbol = process("<ROUTINE GO () <SING 99>>")

        let expected = Statement(
            id: "go",
            code: """
                @discardableResult
                /// The `go` (GO) routine.
                func go() -> Bool {
                    return sing(n: 99)
                }
                """,
            type: .booleanTrue,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("go"), expected)
    }

    func testProcessOneKnownParam() throws {
        let symbol = process("""
            <ROUTINE WEST-HOUSE (RARG)
                 <COND (<EQUAL? .RARG ,M-LOOK>
                    <TELL
                        "You are standing in an open field west of a white house, with a boarded
                        front door.">
                    <COND (,WON-FLAG
                           <TELL
                                " A secret path leads southwest into the forest.">)>
                    <CRLF>)>>
        """)

        let expected = Statement(
            id: "westHouse",
            code: #"""
                /// The `westHouse` (WEST-HOUSE) routine.
                func westHouse(rarg: Int) {
                    if rarg.equals(Globals.mLook) {
                        output("""
                            You are standing in an open field west of a white house, \
                            with a boarded front door.
                            """)
                        if wonFlag {
                            output(" A secret path leads southwest into the forest.")
                        }
                        output("\n")
                    }
                }
                """#,
            type: .void,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("westHouse"), expected)

        XCTAssertNoDifference(symbol.payload?.parameters, [
            Instance(
                Statement(
                    id: "rarg",
                    type: .int,
                    returnHandling: .forced
                ),
                isOptional: false
            ),
        ])
    }

    func testProcessOneUnknownParamUsedInBody() throws {
        let symbol = try factory.init([
            .atom("PRINT-MESSAGE"),
            .list([
                .atom("MESSAGE")
            ]),
            .form([
                .atom("PRINT"),
                .atom("MESSAGE")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "printMessage",
            code: """
                /// The `printMessage` (PRINT-MESSAGE) routine.
                func printMessage(message: String) {
                    output(message)
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))

        XCTAssertNoDifference(symbol.payload?.parameters, [
            Instance(
                Statement(
                    id: "message",
                    type: .string,
                    returnHandling: .forced
                ),
                isOptional: false
            ),
        ])
    }

    func testProcessWithAuxiliaryParams() throws {
        let symbol = try factory.init([
            .atom("DUCKING?"),
            .list([
                .string("AUX"),
                .atom("VS"),
                .atom("PS")
            ]),
            .form([
                .atom("SET"),
                .atom("VS"),
                .decimal(10)
            ]),
            .form([
                .atom("SET"),
                .atom("PS"),
                .string("Duck")
            ]),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "isDucking",
            code: """
                @discardableResult
                /// The `isDucking` (DUCKING?) routine.
                func isDucking() -> String {
                    var vs = 0
                    var ps = ""
                    vs.set(to: 10)
                    return ps.set(to: "Duck")
                }
                """,
            type: .string,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))
    }

    func testProcessWithAuxiliaryParamsWithoutValues() throws {
        let symbol = try factory.init([
            .atom("BOOM-ROOM"),
            .list([
                .string("AUX"),
                .list([
                    .atom("DUMMY?"),
                    .bool(false)
                ])
            ]),
            .form([
                .atom("SET"),
                .atom("DUMMY?"),
                .bool(true)
            ]),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "boomRoom",
            code: """
                @discardableResult
                /// The `boomRoom` (BOOM-ROOM) routine.
                func boomRoom() -> Bool {
                    var isDummy = false
                    return isDummy.set(to: true)
                }
                """,
            type: .booleanTrue,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))
    }

    func testProcessWithOneOptionalParam() throws {
        let symbol = try factory.init([
            .atom("BAT-D"),
            .list([
                .string("OPTIONAL"),
                .atom("FOO")
            ]),
            .form([
                .atom("PRINT"),
                .atom("FOO")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "batD",
            code: """
                /// The `batD` (BAT-D) routine.
                func batD(foo: String? = nil) {
                    output(foo)
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))

        XCTAssertNoDifference(symbol.payload?.parameters, [
            Instance(
                Statement(
                    id: "foo",
                    type: .string,
                    returnHandling: .forced
                ),
                context: .optional,
                isOptional: true
            ),
        ])
    }

    func testProcessWithMultipleOptionalParam() throws {
        let symbol = try factory.init([
            .atom("BAT-BAT"),
            .list([
                .string("OPTIONAL"),
                .atom("FOO"),
                .list([
                    .atom("BAR"),
                    .decimal(42)
                ])
            ]),
            .form([
                .atom("+"),
                .atom("FOO"),
                .atom("BAR")
            ]),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "batBat",
            code: """
                    @discardableResult
                    /// The `batBat` (BAT-BAT) routine.
                    func batBat(foo: Int? = nil, bar: Int = 42) -> Int {
                        return .add(foo, bar)
                    }
                    """,
            type: .int,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))

        XCTAssertNoDifference(symbol.payload?.parameters, [
            Instance(
                Statement(
                    id: "foo",
                    type: .int,
                    returnHandling: .forced
                ),
                context: .optional,
                isOptional: true
            ),
            try Instance(
                Statement(
                    id: "bar",
                    type: .int,
                    returnHandling: .forced
                ),
                context: .optional,
                defaultValue: .literal(42)
            ),
        ])
    }

    func testProcessWithOneDefaultValueParam() throws {
        let symbol = try factory.init([
            .atom("DEAD-FUNCTION"),
            .list([
                .list([
                    .atom("FOO"),
                    .string("****  You have died  ****"),
                ]),
            ]),
            .form([
                .atom("PRINT"),
                .atom("FOO")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "deadFunc",
            code: """
                /// The `deadFunc` (DEAD-FUNCTION) routine.
                func deadFunc(
                    foo: String = "****  You have died  ****"
                ) {
                    output(foo)
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))

        XCTAssertNoDifference(symbol.payload?.parameters, [
            try Instance(
                Statement(
                    id: "foo",
                    type: .string,
                    returnHandling: .forced
                ),
                context: .normal,
                defaultValue: .literal("****  You have died  ****")
            ),
        ])

    }

    func testProcessWithMultipleDefaultValueParam() throws {
        let symbol = process("""
            <CONSTANT F-WEP 0> ;"means print weapon name"
            <CONSTANT F-DEF 1> ;"means print defender name (villain, e.g.)"

            <ROUTINE REMARK (REMARK D W "AUX" (LEN <GET .REMARK 0>) (CNT 0) STR)
                 <REPEAT ()
                         <COND (<G? <SET CNT <+ .CNT 1>> .LEN> <RETURN>)>
                     <SET STR <GET .REMARK .CNT>>
                     <COND (<EQUAL? .STR ,F-WEP> <PRINTD .W>)
                           (<EQUAL? .STR ,F-DEF> <PRINTD .D>)
                           (T <PRINT .STR>)>>
                 <CRLF>>
        """)

        let expected = Statement(
            id: "remark",
            code: #"""
                /// The `remark` (REMARK) routine.
                func remark(remark: Table, d: Object, w: Object) {
                    var len = try remark.get(at: 0)
                    var cnt = 0
                    var str = 0
                    while true {
                        if cnt.set(to: .add(cnt, 1)).isGreaterThan(len) {
                            break
                        }
                        str.set(to: try remark.get(at: cnt))
                        if str.equals(Constants.fWep) {
                            output(w.description)
                        } else if str.equals(Constants.fDef) {
                            output(d.description)
                        } else {
                            output(str)
                        }
                    }
                    output("\n")
                }
                """#,
            type: .void,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("remark"), expected)
    }

    func testProcessRoutineOrMacroWithFactoryOverride() throws {
        let symbol = process("""
            <DEFMAC VERB? ("ARGS" ATMS)
                <MULTIFROB PRSA .ATMS>>
        """)

        XCTAssertNoDifference(symbol, .emptyStatement)
        XCTAssertNil(Game.routines.find("isVerb"))
    }

    func testBottlesRoutine() throws {
        let symbol = process(#"""
            <ROUTINE BOTTLES (N)
                <PRINTN .N>
                <PRINTI " bottle">
                <COND (<N==? .N 1> <PRINTC !\s>)>
                <RTRUE>>
        """#)

        let expected = Statement(
            id: "bottles",
            code: #"""
                @discardableResult
                /// The `bottles` (BOTTLES) routine.
                func bottles(n: Int) -> Bool {
                    output(n)
                    output(" bottle")
                    if n.isNotEqualTo(1) {
                        output("s")
                    }
                    return true
                }
                """#,
            type: .booleanTrue,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("bottles"), expected)
    }

    func testFindWeapon() throws {
        let symbol = process("""
            <ROUTINE FIND-WEAPON (O "AUX" W)
                 <SET W <FIRST? .O>>
                 <COND (<NOT .W>
                    <RFALSE>)>
                 <REPEAT ()
                     <COND (<OR <EQUAL? .W ,STILETTO ,AXE ,SWORD>
                            <EQUAL? .W ,KNIFE ,RUSTY-KNIFE>>
                        <RETURN .W>)
                           (<NOT <SET W <NEXT? .W>>> <RFALSE>)>>>
        """)

        let expected = Statement(
            id: "findWeapon",
            code: #"""
                @discardableResult
                /// The `findWeapon` (FIND-WEAPON) routine.
                func findWeapon(o: Object) -> Object? {
                    var w: Object?
                    w.set(to: o.firstChild)
                    if .isNot(w) {
                        return nil
                    }
                    while true {
                        if .or(
                            w.equals(
                                Objects.stiletto,
                                Objects.axe,
                                Objects.sword
                            ),
                            w.equals(Objects.knife, Objects.rustyKnife)
                        ) {
                            return w
                        } else if .isNot(w.set(to: w.nextSibling)) {
                            return nil
                        }
                    }
                }
                """#,
            type: .object.optional,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("findWeapon"), expected)
    }

    func testDweaponMini() throws {
        try! Game.commit(
            .statement(findWeaponRoutine)
        )

        process("<GLOBAL WINNER 0>")

        let symbol = try factory.init([
            .atom("DWEAPON-MINI"),
            .list([
                .string("AUX"),
                .atom("DWEAPON"),
            ]),
            .form([
                .atom("SET"),
                .atom("DWEAPON"),
                .form([
                    .atom("FIND-WEAPON"),
                    .global(.atom("WINNER"))
                ])
            ]),
            .form([
                .atom("MOVE"),
                .local("DWEAPON"),
                .global(.atom("HERE"))
            ]),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "dweaponMini",
            code: """
                /// The `dweaponMini` (DWEAPON-MINI) routine.
                func dweaponMini() {
                    var dweapon: Object?
                    dweapon.set(to: findWeapon(o: Globals.winner))
                    dweapon.move(to: Rooms.here)
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))
    }

    func testSingRoutine() throws {
        try! Game.commit(.statement(bottlesRoutine))

        let symbol = process("""
            <ROUTINE SING (N)
                <REPEAT ()
                    <BOTTLES .N>
                    <PRINTI " of beer on the wall,|">
                    <BOTTLES .N>
                    <PRINTI " of beer,|Take one down, pass it around,|">
                    <COND
                        (<DLESS? N 1> <PRINTR "No more bottles of beer on the wall!"> <RTRUE>)
                        (ELSE <BOTTLES .N> <PRINTI " of beer on the wall!||">)>>>
        """)

        let expected = Statement(
            id: "sing",
            code: #"""
                @discardableResult
                /// The `sing` (SING) routine.
                func sing(n: Int) -> Bool {
                    var n = n
                    while true {
                        bottles(n: n)
                        output("""
                             of beer on the wall,

                            """)
                        bottles(n: n)
                        output("""
                             of beer,
                            Take one down, pass it around,

                            """)
                        if n.decrement().isLessThan(1) {
                            output("No more bottles of beer on the wall!")
                            output("\n")
                            return true
                        } else {
                            bottles(n: n)
                            output("""
                                 of beer on the wall!


                                """)
                        }
                    }
                }
                """#,
            type: .booleanTrue,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        )

        XCTAssertNoDifference(symbol, .statement(expected))
    }
}

// MARK: - Test helpers

extension RoutineTests {
    var bottlesRoutine: Statement {
        Statement(
            id: "bottles",
            code: """
                @discardableResult
                /// The `bottles` (BOTTLES) routine.
                func bottles(n: Int) -> Bool {
                    output(n)
                    output(" bottle")
                    if n.isNotEqualTo(1) {
                        output("s")
                    }
                    return true
                }
                """,
            type: .booleanTrue,
            payload: .init(
                parameters: [
                    Instance(
                        Statement(
                            id: "n",
                            type: .int
                        )
                    )
                ]
            ),
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        )
    }

    var findWeaponRoutine: Statement {
        Statement(
            id: "findWeapon",
            code: """
                @discardableResult
                /// The `findWeapon` (FIND-WEAPON) routine.
                func findWeapon(o: Object) -> Object? {
                    var w: Object? = nil
                    w.set(to: o.firstChild)
                    if .isNot(w) {
                        return nil
                    }
                    while true {
                        if .or(
                            w.equals(stiletto, axe, sword),
                            w.equals(knife, rustyKnife)
                        ) {
                            return w
                        } else if .isNot(w.set(to: w.nextSibling)) {
                            return nil
                        }
                    }
                }
                """,
            type: .object.optional,
            payload: .init(
                parameters: [
                    Instance(
                        Statement(
                            id: "o",
                            type: .object
                        )
                    ),
                ]
            ),
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        )
    }

    var singSymbol: Statement {
        Statement(
            id: "sing",
            code: #"""
                @discardableResult
                /// The `sing` (SING) routine.
                func sing(n: Int) -> Bool {
                    var n: Int = n
                    while true {
                        bottles(n: n)
                        output("""
                             of beer on the wall,

                            """)
                        bottles(n: n)
                        output("""
                             of beer,
                            Take one down, pass it around,

                            """)
                        if n.decrement().isLessThan(1) {
                            output("No more bottles of beer on the wall!")
                            output("\n")
                            return true
                        } else {
                            bottles(n: n)
                            output("""
                                 of beer on the wall!


                                """)
                        }
                    }
                }
                """#,
            type: .booleanTrue,
            payload: .init(
                parameters: [
                    Instance(
                        Statement(id: "n", type: .int)
                    )
                ]
            ),
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        )
    }
}
