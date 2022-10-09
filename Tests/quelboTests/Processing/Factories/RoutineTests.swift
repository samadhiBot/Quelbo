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
            .variable(id: "fDef", type: .int),
            .variable(id: "fWep", type: .int),
            .variable(id: "here", type: .object, category: .rooms),
            .variable(id: "knife", type: .object, category: .objects),
            .variable(id: "mLook", type: .int),
            .variable(id: "rustyKnife", type: .object, category: .objects),
            .variable(id: "stiletto", type: .object, category: .objects),
            .variable(id: "sword", type: .object, category: .objects),
            .variable(id: "wonFlag", type: .bool),
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
                    // <STUPID-CONTAINER ,BAG-OF-COINS 'coins'>
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("bagOfCoinsFunc"), expected)
    }

    func testProcessZeroParamsOneExpression() throws {
        let symbol = process("<ROUTINE GO () <SING 99>>")

        let expected = Statement(
            id: "go",
            code: """
                /// The `go` (GO) routine.
                func go() {
                    sing(n: 99)
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true
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
                    if rarg.equals(mLook) {
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
            parameters: [
                Instance(
                    Variable(id: "rarg", type: .int)
                ),
            ],
            category: .routines,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("westHouse"), expected)
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
            parameters: [
                Instance(
                    Variable(
                        id: "message",
                        type: .string
                    )
                )
            ],
            category: .routines,
            isCommittable: true
        ))
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
                    var vs: Int = 0
                    var ps: String = ""
                    vs.set(to: 10)
                    return ps.set(to: "Duck")
                }
                """,
            type: .string,
            category: .routines,
            isCommittable: true
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
                    var isDummy: Bool = false
                    return isDummy.set(to: true)
                }
                """,
            type: .booleanTrue,
            category: .routines,
            isCommittable: true
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
                func batD(foo: String = "") {
                    output(foo)
                }
                """,
            type: .void,
            parameters: [
                Instance(
                    Variable(
                        id: "foo",
                        type: .string
                    ),
                    isOptional: true
                ),
            ],
            category: .routines,
            isCommittable: true
        ))
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
                    func batBat(
                        foo: Int = 0,
                        bar: Int = 42
                    ) -> Int {
                        return .add(foo, bar)
                    }
                    """,
            type: .int,
            parameters: [
                Instance(
                    Variable(
                        id: "foo",
                        type: .int
                    ),
                    isOptional: true
                ),
                Instance(
                    Variable(
                        id: "bar",
                        type: .int
                    ),
                    isOptional: true
                )
            ],
            category: .routines,
            isCommittable: true
        ))
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
            parameters: [
                Instance(
                    Variable(
                        id: "foo",
                        type: .string
                    )
                )
            ],
            category: .routines,
            isCommittable: true
        ))
    }

    func testProcessWithMultipleDefaultValueParam() throws {
        let symbol = process("""
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
                func remark(
                    remark: Table,
                    d: Object,
                    w: Object
                ) {
                    var len: ZilElement = try remark.get(at: 0)
                    var cnt: Int = 0
                    var str: ZilElement = .none
                    while true {
                        if cnt.set(to: .add(cnt, 1)).isGreaterThan(len) {
                            break
                        }
                        str.set(to: try remark.get(at: cnt))
                        if str.equals(fWep) {
                            output(w.description)
                        } else if str.equals(fDef) {
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
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("remark"), expected)
    }

    func testBottlesRoutine() throws {
        let symbol = process(#"""
            <ROUTINE BOTTLES (N)
                <PRINTN .N>
                <PRINTI " bottle">
                <COND (<N==? .N 1> <PRINTC !\s>)>
                <RTRUE>>
        """#)

        XCTAssertNoDifference(symbol, .statement(bottlesRoutine))
        XCTAssertNoDifference(Game.routines.find("bottles"), bottlesRoutine)
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

        XCTAssertNoDifference(symbol, .statement(findWeaponRoutine))
        XCTAssertNoDifference(Game.routines.find("findWeapon"), findWeaponRoutine)
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
                    var dweapon: Object? = nil
                    dweapon.set(to: findWeapon(o: winner))
                    dweapon.move(to: here)
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true
        ))
    }

    func testRemoveCarefully() throws {
        try! Game.commit([
            .statement(findWeaponRoutine),
            .variable(id: "pItObject", type: .object, category: .objects),
        ])

        process("<GLOBAL LIT <>>")

        let symbol = process("""
            <ROUTINE REMOVE-CAREFULLY (OBJ "AUX" OLIT)
                 <COND (<EQUAL? .OBJ ,P-IT-OBJECT>
                    <SETG P-IT-OBJECT <>>)>
                 <SET OLIT ,LIT>
                 <REMOVE .OBJ>
                 <SETG LIT <LIT? ,HERE>>
                 <COND (<AND .OLIT <NOT <EQUAL? .OLIT ,LIT>>>
                    <TELL "You are left in the dark..." CR>)>
                 T>
        """)

        let expected = Statement(
            id: "removeCarefully",
            code: """
                @discardableResult
                /// The `removeCarefully` (REMOVE-CAREFULLY) routine.
                func removeCarefully(obj: Object) -> Bool {
                    var olit: Bool = false
                    if obj.equals(pItObject) {
                        pItObject.set(to: nil)
                    }
                    olit.set(to: lit)
                    obj.remove()
                    lit.set(to: isLit())
                    if .and(
                        olit,
                        .isNot(olit.equals(lit))
                    ) {
                        output("You are left in the dark...")
                    }
                    return true
                }
                """,
            type: .booleanTrue,
            parameters: [
                Instance(
                    Variable(
                        id: "obj",
                        type: .object
                    )
                ),
            ],
            category: .routines,
            isCommittable: true
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("removeCarefully"), expected)
    }

    func testSingRoutine() throws {
        try! Game.commit(.statement(bottlesRoutine))

        let symbol = try factory.init([
            .atom("SING"),
            .list([
                .atom("N")
            ]),
            .form([
                .atom("REPEAT"),
                .list([
                ]),
                .form([
                    .atom("BOTTLES"),
                    .local("N")
                ]),
                .form([
                    .atom("PRINTI"),
                    .string("""
                         of beer on the wall,
                        """)
                ]),
                .form([
                    .atom("BOTTLES"),
                    .local("N")
                ]),
                .form([
                    .atom("PRINTI"),
                    .string("""
                         of beer,
                        Take one down, pass it around,
                        """)
                ]),
                .form([
                    .atom("COND"),
                    .list([
                        .form([
                            .atom("DLESS?"),
                            .atom("N"),
                            .decimal(1)
                        ]),
                        .form([
                            .atom("PRINTR"),
                            .string("No more bottles of beer on the wall!")
                        ]),
                        .form([
                            .atom("RETURN")
                        ])
                    ]),
                    .list([
                        .atom("ELSE"),
                        .form([
                            .atom("BOTTLES"),
                            .local("N")
                        ]),
                        .form([
                            .atom("PRINTI"),
                            .string(
                                """
                                 of beer on the wall!

                                """
                            )
                        ])
                    ])
                ])
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(singSymbol))
    }

    func testIntRoutine() throws {
        let symbol = process("""
            <CONSTANT C-INTLEN 6>
            <CONSTANT C-RTN 2>
            <GLOBAL C-INTS 180>
            <GLOBAL C-DEMONS 180>
            <GLOBAL C-TABLE <ITABLE NONE 180>>
            <CONSTANT C-TABLELEN 180>

            <ROUTINE INT (RTN "OPTIONAL" (DEMON <>) E C INT)
                 #DECL ((RTN) ATOM (DEMON) <OR ATOM FALSE> (E C INT) <PRIMTYPE VECTOR>)
                 <SET E <REST ,C-TABLE ,C-TABLELEN>>
                 <SET C <REST ,C-TABLE ,C-INTS>>
                 <REPEAT ()
                     <COND (<==? .C .E>
                        <SETG C-INTS <- ,C-INTS ,C-INTLEN>>
                        <AND .DEMON <SETG C-DEMONS <- ,C-DEMONS ,C-INTLEN>>>
                        <SET INT <REST ,C-TABLE ,C-INTS>>
                        <PUT .INT ,C-RTN .RTN>
                        <RETURN .INT>)
                           (<EQUAL? <GET .C ,C-RTN> .RTN> <RETURN .C>)>
                     <SET C <REST .C ,C-INTLEN>>>>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "int",
            code: """
                @discardableResult
                /// The `int` (INT) routine.
                func int(
                    rtn: ZilElement,
                    demon: Bool = false,
                    e: Table? = nil,
                    c: Table? = nil,
                    int: Table? = nil
                ) -> Table {
                    var e: Table = e
                    var c: Table = c
                    var int: Table = int
                    e.set(to: cTable.rest(cTablelen))
                    c.set(to: cTable.rest(cInts))
                    while true {
                        if c.equals(e) {
                            cInts.set(to: .subtract(cInts, cIntlen))
                            .and(
                                demon,
                                cDemons.set(to: .subtract(cDemons, cIntlen))
                            )
                            int.set(to: cTable.rest(cInts))
                            try int.put(element: rtn, at: cRtn)
                            return int
                        } else if try c.get(at: cRtn).equals(rtn) {
                            return c
                        }
                        return c.set(to: c.rest(cIntlen))
                    }
                }
                """,
            type: .table,
            category: .routines,
            isCommittable: true
        ))
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
            parameters: [
                Instance(
                    Variable(
                        id: "n",
                        type: .int
                    )
                )
            ],
            category: .routines,
            isCommittable: true
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
            type: .optional(.object),
            parameters: [
                Instance(
                    Variable(
                        id: "o",
                        type: .object
                    )
                ),
            ],
            category: .routines,
            isCommittable: true
        )
    }

    var singSymbol: Statement {
        Statement(
            id: "sing",
            code: #"""
            /// The `sing` (SING) routine.
            func sing(n: Int) {
                var n: Int = n
                while true {
                    bottles(n: n)
                    output(" of beer on the wall,")
                    bottles(n: n)
                    output("""
                         of beer,
                        Take one down, pass it around,
                        """)
                    if n.decrement().isLessThan(1) {
                        output("No more bottles of beer on the wall!")
                        output("\n")
                        break
                    } else {
                        bottles(n: n)
                        output("""
                             of beer on the wall!

                            """)
                    }
                }
            }
            """#,
            type: .void,
            parameters: [
                Instance(
                    Variable(
                        id: "n",
                        type: .int
                    )
                )
            ],
            category: .routines,
            isCommittable: true
        )
    }
}
