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
            Symbol(
                "sing",
                type: .void,
                category: .routines,
                children: [
                    Symbol(id: "n", code: "n: Int", type: .int)
                ]
            )
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
            ]),
            .form([
                .atom("PRINTN"),
                .local("CNT")
            ])
        ]).process()

        let expected = Symbol(
            id: "remark",
            code: """
                /// The `remark` (REMARK) routine.
                func remark(
                    len: ZilElement = remark[0],
                    cnt: Int = 0
                ) {
                    output(cnt)
                }
                """,
            type: .void,
            category: .routines,
            children: [
                Symbol(
                    id: "[len, remark[0]]",
                    code: "len: ZilElement = remark[0]",
                    type: .array(.zilElement),
                    children: [
                        Symbol("len", type: .zilElement),
                        Symbol(
                            "remark[0]",
                            type: .zilElement,
                            children: [
                                Symbol("remark", type: .array(.zilElement)),
                                Symbol("0", type: .int, meta: [.isLiteral])
                            ]
                        )
                    ]
                ),
                Symbol(
                    id: "[cnt, 0]",
                    code: "cnt: Int = 0",
                    type: .array(.int),
                    children: [
                        Symbol("cnt", type: .int),
                        Symbol("0", type: .int, meta: [.isLiteral])
                    ]
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("remark", category: .routines), expected)
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

        XCTAssertNoDifference(symbol, Symbol(
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
        ))
    }
}

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
}
