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
                category: .routines
            ),
            .statement(singSymbol),
            .variable(id: "axe", type: .object, category: .objects),
            .variable(id: "fDef", type: .int),
            .variable(id: "fWep", type: .int),
            .variable(id: "here", type: .object, category: .rooms),
            .variable(id: "knife", type: .object, category: .objects),
            .variable(id: "rustyKnife", type: .object, category: .objects),
            .variable(id: "stiletto", type: .object, category: .objects),
            .variable(id: "sword", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("ROUTINE"))
    }

    func testProcessZeroParamsZeroExpressions() throws {
        let symbol = try factory.init([
            .atom("BAG-OF-COINS-F"),
            .list([]),
            .commented(.atom("noop")),
        ], with: &localVariables).process()

        let expected = Statement(
            id: "bagOfCoinsFunc",
            code: """
                /// The `bagOfCoinsFunc` (BAG-OF-COINS-F) routine.
                func bagOfCoinsFunc() {
                    // noop
                }
                """,
            type: .void,
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("bagOfCoinsFunc"), expected)
    }

    func testProcessZeroParamsOneExpression() throws {
        let symbol = try factory.init([
            .atom("GO"),
            .list([]),
            .form([
                .atom("SING"),
                .decimal(99),
            ]),
        ], with: &localVariables).process()

        let expected = Statement(
            id: "go",
            code: """
                /// The `go` (GO) routine.
                func go() {
                    sing(n: 99)
                }
                """,
            type: .void,
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("go"), expected)
    }

    func testProcessOneKnownParam() throws {
        let symbol = try factory.init([
            .atom("WEST-HOUSE"),
            .list([
                .atom("RARG")
            ]),
            .form([
                .atom("ADD"),
                .atom("RARG"),
                .decimal(42)
            ])
        ], with: &localVariables).process()

        let expected = Statement(
            id: "westHouse",
            code: """
                @discardableResult
                /// The `westHouse` (WEST-HOUSE) routine.
                func westHouse(rarg: Int) -> Int {
                    var rarg: Int = rarg
                    return rarg.add(42)
                }
                """,
            type: .int,
            parameters: [
                Instance(
                    Variable(
                        id: "rarg",
                        type: .int
                    )
                ),
            ],
            category: .routines
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

        let expected = Statement(
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
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("printMessage"), expected)
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

        let expected = Statement(
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
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("isDucking"), expected)
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

        let expected = Statement(
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
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("boomRoom"), expected)
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

        let expected = Statement(
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
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("batD"), expected)
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

        let expected = Statement(
            id: "batBat",
            code: """
                    @discardableResult
                    /// The `batBat` (BAT-BAT) routine.
                    func batBat(
                        foo: Int = 0,
                        bar: Int = 42
                    ) -> Int {
                        var foo: Int = foo
                        return foo.add(bar)
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
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("batBat"), expected)
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

        let expected = Statement(
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
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("deadFunc"), expected)
    }

    func testProcessWithMultipleDefaultValueParam() throws {
        let symbol = try factory.init(
            try parse("""
                <ROUTINE REMARK (REMARK D W "AUX" (LEN <GET .REMARK 0>) (CNT 0) STR)
                     <REPEAT ()
                             <COND (<G? <SET CNT <+ .CNT 1>> .LEN> <RETURN>)>
                         <SET STR <GET .REMARK .CNT>>
                         <COND (<EQUAL? .STR ,F-WEP> <PRINTD .W>)
                               (<EQUAL? .STR ,F-DEF> <PRINTD .D>)
                               (T <PRINT .STR>)>>
                     <CRLF>>
                """).droppingFirst,
            with: &localVariables
        ).process()

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
                        if cnt.set(to: cnt.add(1)).isGreaterThan(len) {
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
            parameters: [
                Instance(
                    Variable(
                        id: "remark",
                        type: .oneOf([.table, .zilElement, .array(.zilElement)])
                    )
                ),
                Instance(
                    Variable(
                        id: "d",
                        type: .object
                    )
                ),
                Instance(
                    Variable(
                        id: "w",
                        type: .object
                    )
                ),
            ],
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("remark"), expected)
    }

    // <ROUTINE THIEF-VS-ADVENTURER (HERE? "AUX" ROBBED? (WINNER-ROBBED? <>))

    // <ROUTINE ROBBER-FUNCTION ("OPTIONAL" (MODE <>) "AUX" (FLG <>) X N)

    // <ROUTINE I-LANTERN ("AUX" TICK (TBL <VALUE LAMP-TABLE>))

    func testBottlesRoutine() throws {
        let symbol = try factory.init([
            .atom("BOTTLES"),
            .list([
                .atom("N")
            ]),
            .form([
                .atom("PRINTN"),
                .local("N")
            ]),
            .form([
                .atom("PRINTI"),
                .string(" bottle")
            ]),
            .form([
                .atom("COND"),
                .list([
                    .form([
                        .atom("N==?"),
                        .local("N"),
                        .decimal(1)
                    ]),
                    .form([
                        .atom("PRINTC"),
                        .character("s")
                    ])
                ])
            ]),
            .form([
                .atom("RTRUE")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(bottlesRoutine))
        XCTAssertNoDifference(Game.routines.find("bottles"), bottlesRoutine)
    }

    func testFindWeapon() throws {
        let symbol = try factory.init(
            try parse("""
                <ROUTINE FIND-WEAPON (O "AUX" W)
                     <SET W <FIRST? .O>>
                     <COND (<NOT .W>
                        <RFALSE>)>
                     <REPEAT ()
                         <COND (<OR <EQUAL? .W ,STILETTO ,AXE ,SWORD>
                                <EQUAL? .W ,KNIFE ,RUSTY-KNIFE>>
                            <RETURN .W>)
                               (<NOT <SET W <NEXT? .W>>> <RFALSE>)>>>
            """).droppingFirst,
            with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(findWeaponRoutine))
        XCTAssertNoDifference(Game.routines.find("findWeapon"), findWeaponRoutine)
    }

    func testDweaponMini() throws {
        try! Game.commit(
            .statement(findWeaponRoutine)
        )

        try Factories.Global([
            .atom("WINNER"),
            .decimal(0)
        ], with: &localVariables).process()

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
                    .global("WINNER")
                ])
            ]),
            .form([
                .atom("MOVE"),
                .local("DWEAPON"),
                .global("HERE")
            ]),
        ], with: &localVariables).process()

        let expected = Statement(
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
            category: .routines
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("dweaponMini"), expected)
    }

    func testRemoveCarefully() throws {
        try! Game.commit([
            .statement(findWeaponRoutine),
            .variable(id: "pItObject", type: .object, category: .objects),
        ])

        try Factories.Global([
            .atom("LIT"),
            .bool(false)
        ], with: &localVariables).process()

        let symbol = try factory.init([
            .atom("REMOVE-CAREFULLY"),
            .list([
                .atom("OBJ"),
                .string("AUX"),
                .atom("OLIT")
            ]),
            .form([
                .atom("COND"),
                .list([
                    .form([
                        .atom("EQUAL?"),
                        .local("OBJ"),
                        .global("P-IT-OBJECT")
                    ]),
                    .form([
                        .atom("SETG"),
                        .atom("P-IT-OBJECT"),
                        .bool(false)
                    ])
                ])
            ]),
            .form([
                .atom("SET"),
                .atom("OLIT"),
                .global("LIT")
            ]),
            .form([
                .atom("REMOVE"),
                .local("OBJ")
            ]),
            .form([
                .atom("SETG"),
                .atom("LIT"),
                .form([
                    .atom("LIT?"),
                    .global("HERE")
                ])
            ]),
            .form([
                .atom("COND"),
                .list([
                    .form([
                        .atom("AND"),
                        .local("OLIT"),
                        .form([
                            .atom("NOT"),
                            .form([
                                .atom("EQUAL?"),
                                .local("OLIT"),
                                .global("LIT")
                            ])
                        ])
                    ]),
                    .form([
                        .atom("TELL"),
                        .string("You are left in the dark..."),
                        .atom("CR")
                    ])
                ])
            ]),
            .atom("T")
        ], with: &localVariables).process()

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
            category: .routines
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
        try! Game.commit([
            .variable(id: "cIntlen", type: .int, category: .constants),
            .variable(id: "cRtn", type: .int, category: .constants),
            .variable(id: "cInts", type: .int, category: .globals),
            .variable(id: "cDemons", type: .int, category: .globals),
            .variable(id: "cTable", type: .table, category: .globals),
            .variable(id: "cTablelen", type: .int, category: .globals),
        ])

        let definition = try parse("""
            <ROUTINE INT (RTN "OPTIONAL" (DEMON <>) E C INT)
                 #DECL ((RTN) ATOM (DEMON) <OR ATOM FALSE> (E C INT) <PRIMTYPE
                                              VECTOR>)
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
        """).droppingFirst
        let symbol = try factory.init(definition, with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "int",
            code: """
                @discardableResult
                /// The `int` (INT) routine.
                func int(
                    rtn: ZilElement,
                    demon: Int = 0,
                    e: Table? = nil,
                    c: Table? = nil,
                    int: Table? = nil
                ) -> Table {
                    var e: Table = e
                    var c: Table = c
                    var int: Table = int
                    // Declare(
                    //     rtn: atom,
                    //     demon: .or(atom, false),
                    //     e: Array,
                    //     c: Array,
                    //     int: Array
                    // )
                    e.set(to: cTable.rest(cTablelen))
                    c.set(to: cTable.rest(cInts))
                    while true {
                        if c.equals(e) {
                            cInts.set(to: cInts.subtract(cIntlen))
                            .and(
                                demon,
                                cDemons.set(to: cDemons.subtract(cIntlen))
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
            parameters: [
                Instance(Variable(id: "rtn", type: .zilElement)),
                Instance(Variable(id: "demon", type: .int), isOptional: true),
                Instance(Variable(id: "e", type: .table, category: .globals, isMutable: true), isOptional: true),
                Instance(Variable(id: "c", type: .table, category: .globals, isMutable: true), isOptional: true),
                Instance(Variable(id: "int", type: .table, category: .globals, isMutable: true), isOptional: true),
            ],
            category: .routines
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
            category: .routines
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
            category: .routines
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
            category: .routines
        )
    }
}
