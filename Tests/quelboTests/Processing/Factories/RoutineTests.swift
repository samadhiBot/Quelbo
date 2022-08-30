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
                confidence: .certain,
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
            confidence: .void,
            category: .routines,
            returnable: .void
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
            confidence: .void,
            category: .routines,
            returnable: .void
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
            confidence: .certain,
            parameters: [
                Instance(
                    Variable(
                        id: "rarg",
                        type: .int,
                        confidence: .certain
                    )
                ),
            ],
            category: .routines,
            returnable: .void
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
            confidence: .void,
            parameters: [
                Instance(
                    Variable(
                        id: "message",
                        type: .string,
                        confidence: .certain
                    )
                )
            ],
            category: .routines,
            returnable: .void
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
            confidence: .certain,
            category: .routines,
            returnable: .void
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
            type: .bool,
            confidence: .booleanTrue,
            category: .routines,
            returnable: .void
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
            confidence: .void,
            parameters: [
                Instance(
                    Variable(
                        id: "foo",
                        type: .string,
                        confidence: .certain
                    ),
                    isOptional: true
                ),
            ],
            category: .routines,
            returnable: .void
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
            confidence: .certain,
            parameters: [
                Instance(
                    Variable(
                        id: "foo",
                        type: .int,
                        confidence: .certain
                    ),
                    isOptional: true
                ),
                Instance(
                    Variable(
                        id: "bar",
                        type: .int,
                        confidence: .certain
                    ),
                    isOptional: true
                )
            ],
            category: .routines,
            returnable: .void
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
            confidence: .void,
            parameters: [
                Instance(
                    Variable(
                        id: "foo",
                        type: .string,
                        confidence: .certain
                    )
                )
            ],
            category: .routines,
            returnable: .void
        )

        XCTAssertNoDifference(symbol, .statement(expected))
        XCTAssertNoDifference(Game.routines.find("deadFunc"), expected)
    }

    // <ROUTINE REMARK (REMARK D W "AUX" (LEN <GET .REMARK 0>) (CNT 0) STR)

    func testProcessWithMultipleDefaultValueParam() throws {
        let symbol = try factory.init([
            .atom("REMARK"),
            .list([
                .atom("REMARK"),
                .atom("D"),
                .atom("W"),
                .string("AUX"),
                .list([
                    .atom("LEN"),
                    .form([
                        .atom("GET"),
                        .local("REMARK"),
                        .decimal(0)
                    ])
                ]),
                .list([
                    .atom("CNT"),
                    .decimal(0)
                ]),
                .atom("STR")
            ]),
            .form([
                .atom("REPEAT"),
                .list([
                ]),
                .form([
                    .atom("COND"),
                    .list([
                        .form([
                            .atom("G?"),
                            .form([
                                .atom("SET"),
                                .atom("CNT"),
                                .form([
                                    .atom("+"),
                                    .local("CNT"),
                                    .decimal(1)
                                ])
                            ]),
                            .local("LEN")
                        ]),
                        .form([
                            .atom("RETURN")
                        ])
                    ])
                ]),
                .form([
                    .atom("SET"),
                    .atom("STR"),
                    .form([
                        .atom("GET"),
                        .local("REMARK"),
                        .local("CNT")
                    ])
                ]),
                .form([
                    .atom("COND"),
                    .list([
                        .form([
                            .atom("EQUAL?"),
                            .local("STR"),
                            .global("F-WEP")
                        ]),
                        .form([
                            .atom("PRINTD"),
                            .local("W")
                        ])
                    ]),
                    .list([
                        .form([
                            .atom("EQUAL?"),
                            .local("STR"),
                            .global("F-DEF")
                        ]),
                        .form([
                            .atom("PRINTD"),
                            .local("D")
                        ])
                    ]),
                    .list([
                        .atom("T"),
                        .form([
                            .atom("PRINT"),
                            .local("STR")
                        ])
                    ])
                ])
            ]),
            .form([
                .atom("CRLF")
            ])
        ], with: &localVariables).process()

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
                    var str: String = ""
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
            confidence: .void,
            parameters: [
                Instance(
                    Variable(
                        id: "remark",
                        type: .table,
                        confidence: .certain
                    )
                ),
                Instance(
                    Variable(
                        id: "d",
                        type: .object,
                        confidence: .certain
                    )
                ),
                Instance(
                    Variable(
                        id: "w",
                        type: .object,
                        confidence: .certain
                    )
                ),
            ],
            category: .routines,
            returnable: .void
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
        let symbol = try factory.init([
            .atom("FIND-WEAPON"),
            .list([
                .atom("O"),
                .string("AUX"),
                .atom("W")
            ]),
            .form([
                .atom("SET"),
                .atom("W"),
                .form([
                    .atom("FIRST?"),
                    .local("O")
                ])
            ]),
            .form([
                .atom("COND"),
                .list([
                    .form([
                        .atom("NOT"),
                        .local("W")
                    ]),
                    .form([
                        .atom("RFALSE")
                    ])
                ])
            ]),
            .form([
                .atom("REPEAT"),
                .list([
                ]),
                .form([
                    .atom("COND"),
                    .list([
                        .form([
                            .atom("OR"),
                            .form([
                                .atom("EQUAL?"),
                                .local("W"),
                                .global("STILETTO"),
                                .global("AXE"),
                                .global("SWORD")
                            ]),
                            .form([
                                .atom("EQUAL?"),
                                .local("W"),
                                .global("KNIFE"),
                                .global("RUSTY-KNIFE")
                            ])
                        ]),
                        .form([
                            .atom("RETURN"),
                            .local("W")
                        ])
                    ]),
                    .list([
                        .form([
                            .atom("NOT"),
                            .form([
                                .atom("SET"),
                                .atom("W"),
                                .form([
                                    .atom("NEXT?"),
                                    .local("W")
                                ])
                            ])
                        ]),
                        .form([
                            .atom("RFALSE")
                        ])
                    ])
                ])
            ])
        ], with: &localVariables).process()

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
            confidence: .void,
            category: .routines,
            returnable: .void
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
            type: .bool,
            confidence: .booleanTrue,
            parameters: [
                Instance(
                    Variable(
                        id: "obj",
                        type: .object,
                        confidence: .certain
                    )
                ),
            ],
            category: .routines,
            returnable: .void
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
            type: .bool,
            confidence: .booleanTrue,
            parameters: [
                Instance(
                    Variable(
                        id: "n",
                        type: .int,
                        confidence: .certain
                    )
                )
            ],
            category: .routines,
            returnable: .void
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
            confidence: .certain,
            parameters: [
                Instance(
                    Variable(
                        id: "o",
                        type: .object,
                        confidence: .certain
                    )
                ),
            ],
            category: .routines,
            returnable: .void
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
            confidence: .void,
            parameters: [
                Instance(
                    Variable(
                        id: "n",
                        type: .int,
                        confidence: .certain
                    )
                )
            ],
            category: .routines,
            returnable: .void
        )
    }
}
