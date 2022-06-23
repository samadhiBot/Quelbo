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
            Symbol("axe", type: .object, category: .objects),
            Symbol("fDef", type: .int),
            Symbol("fWep", type: .int),
            Symbol("here", type: .object, category: .rooms),
            Symbol("isLit", type: .bool, category: .routines),
            Symbol("knife", type: .object, category: .objects),
            Symbol("rustyKnife", type: .object, category: .objects),
            Symbol("stiletto", type: .object, category: .objects),
            Symbol("sword", type: .object, category: .objects),
            singSymbol
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("ROUTINE"))
    }

    func testProcessZeroParamsZeroExpressions() throws {
        let symbol = try factory.init([
            .atom("BAG-OF-COINS-F"),
            .list([]),
            .commented(.atom("noop")),
        ]).process()

        let expected = Symbol(
            id: "bagOfCoinsFunc",
            code: """
                /// The `bagOfCoinsFunc` (BAG-OF-COINS-F) routine.
                func bagOfCoinsFunc() {
                    /* noop */
                }
                """,
            type: .void,
            category: .routines
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("bagOfCoinsFunc", category: .routines), expected)
    }

    func testProcessZeroParamsOneExpression() throws {
        let symbol = try factory.init([
            .atom("GO"),
            .list([]),
            .form([
                .atom("SING"),
                .decimal(99),
            ]),
        ]).process()

        let expected = Symbol(
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

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("go", category: .routines), expected)
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
        ]).process()

        let expected = Symbol(
            id: "westHouse",
            code: """
                @discardableResult
                /// The `westHouse` (WEST-HOUSE) routine.
                func westHouse(rarg: Int) -> Int {
                    var rarg = rarg
                    return rarg.add(42)
                }
                """,
            type: .int,
            category: .routines,
            children: [
                Symbol(
                    id: "rarg",
                    code: "rarg: Int",
                    type: .int,
                    meta: [.mutating(true)]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("westHouse", category: .routines), expected)
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
        ]).process()

        let expected = Symbol(
            id: "printMessage",
            code: """
                /// The `printMessage` (PRINT-MESSAGE) routine.
                func printMessage(message: String) {
                    output(message)
                }
                """,
            type: .void,
            category: .routines,
            children: [
                Symbol(
                    id: "message",
                    code: "message: String",
                    type: .string
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("printMessage", category: .routines), expected)
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
        ]).process()

        let expected = Symbol(
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

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("isDucking", category: .routines), expected)
    }

    func testProcessWithAuxiliaryParamsWithDefaultValues() throws {
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
        ]).process()

        let expected = Symbol(
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
            category: .routines
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("boomRoom", category: .routines), expected)
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
        ]).process()

        let expected = Symbol(
            id: "batD",
            code: """
                    /// The `batD` (BAT-D) routine.
                    func batD(foo: String? = nil) {
                        output(foo)
                    }
                    """,
            type: .void,
            category: .routines,
            children: [
                Symbol(
                    id: "foo",
                    code: "foo: String? = nil",
                    type: .string
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("batD", category: .routines), expected)
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
        ]).process()

        let expected = Symbol(
            id: "batBat",
            code: """
                    @discardableResult
                    /// The `batBat` (BAT-BAT) routine.
                    func batBat(
                        foo: Int? = nil,
                        bar: Int = 42
                    ) -> Int {
                        var foo = foo
                        return foo.add(bar)
                    }
                    """,
            type: .int,
            category: .routines,
            children: [
                Symbol(id: "foo", code: "foo: Int? = nil", type: .int, meta: [.mutating(true)]),
                Symbol(
                    id: "[bar, 42]",
                    code: "bar: Int = 42",
                    type: .array(.int),
                    children: [
                        Symbol("bar", type: .int),
                        Symbol("42", type: .int, meta: [.isLiteral]),
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("batBat", category: .routines), expected)
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
        ]).process()

        let expected = Symbol(
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
            children: [
                Symbol(
                    id: """
                        [
                            foo,
                            "****  You have died  ****",
                        ]
                        """,
                    code: "foo: String = \"****  You have died  ****\"",
                    type: .array(.string),
                    children: [
                        Symbol("foo", type: .string),
                        Symbol("\"****  You have died  ****\"", type: .string, meta: [.isLiteral])
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("deadFunc", category: .routines), expected)
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
        ]).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            id: "remark",
            code: #"""
                /// The `remark` (REMARK) routine.
                func remark(
                    remark: Table,
                    d: Object,
                    w: Object
                ) {
                    var str: ZilElement = .none
                    var len: ZilElement = try remark.get(at: 0)
                    var cnt: Int = 0
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
            category: .routines
        ))
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
        ]).process()

        XCTAssertNoDifference(symbol, bottlesRoutine)
        XCTAssertNoDifference(try Game.find("bottles", category: .routines), bottlesRoutine)
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
        ]).process()

        XCTAssertNoDifference(symbol, findWeaponRoutine)
        XCTAssertNoDifference(try Game.find("findWeapon", category: .routines), findWeaponRoutine)
    }

    func testDweaponMini() throws {
        try! Game.commit(findWeaponRoutine)

        let _ = try Factories.Global([
            .atom("HERE"),
            .decimal(0)
        ]).process()

        let _ = try Factories.Global([
            .atom("WINNER"),
            .decimal(0)
        ]).process()

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
        ]).process()

        let expected = Symbol(
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

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("dweaponMini", category: .routines), expected)
    }

    func testRemoveCarefully() throws {
        try! Game.commit(findWeaponRoutine)

        let _ = try Factories.Global([
            .atom("LIT"),
            .bool(false)
        ]).process()

        let _ = try Factories.Global([
            .atom("P-IT-OBJECT"),
            .bool(false)
        ]).process()

//        let _ = try Factories.Global([
//            .atom("WINNER"),
//            .decimal(0)
//        ]).process()

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
        ]).process()

        let expected = Symbol(
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
            category: .routines
        )

        XCTAssertNoDifference(symbol, expected)
//        XCTAssertNoDifference(try Game.find("dweaponMini", category: .routines), expected)
    }

    func testSingRoutine() throws {
        try! Game.commit(bottlesRoutine)

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
        ]).process()

        XCTAssertNoDifference(symbol, singSymbol)
    }


    
}

// MARK: - Test helpers

extension RoutineTests {
    var bottlesRoutine: Symbol {
        Symbol(
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
            category: .routines,
            children: [
                Symbol(id: "n", code: "n: Int", type: .int)
            ]
        )
    }

    var findWeaponRoutine: Symbol {
        Symbol(
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
            category: .routines,
            children: [
                Symbol(id: "o", code: "o: Object", type: .object)
            ]
        )
    }

    var singSymbol: Symbol {
        Symbol(
            id: "sing",
            code: #"""
            /// The `sing` (SING) routine.
            func sing(n: Int) {
                var n = n
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
            category: .routines,
            children: [
                Symbol(
                    id: "n",
                    code: "n: Int",
                    type: .int
                )
            ]
        )
    }
}
