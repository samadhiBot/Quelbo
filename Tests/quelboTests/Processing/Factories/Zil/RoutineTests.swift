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

        try! Game.commit(
            Symbol(
                "sing",
                type: .int,
                category: .routines,
                children: [
                    Symbol("n", type: .int)
                ]
            )
        )
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
                func go() -> Int {
                    sing(n: 99)
                }
                """,
            type: .int,
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
                /// The `westHouse` (WEST-HOUSE) routine.
                func westHouse(rarg: Int) -> Int {
                    rarg.add(42)
                }
                """,
            type: .int,
            category: .routines,
            children: [
                Symbol(
                    id: "rarg",
                    code: "rarg: Int",
                    type: .int
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
                /// The `isDucking` (DUCKING?) routine.
                func isDucking() -> String {
                    var vs: Int
                    var ps: String

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
                /// The `boomRoom` (BOOM-ROOM) routine.
                func boomRoom() -> Bool {
                    var isDummy: Bool = false

                    isDummy.set(to: true)
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
                    /// The `batBat` (BAT-BAT) routine.
                    func batBat(foo: Int? = nil, bar: Int = 42) -> Int {
                        foo.add(bar)
                    }
                    """,
            type: .int,
            category: .routines,
            children: [
                Symbol(id: "foo", code: "foo: Int? = nil", type: .int),
                Symbol(
                    id: "<List>",
                    code: "bar: Int = 42",
                    type: .list,
                    children: [
                        Symbol("bar", type: .int),
                        Symbol("42", type: .int),
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
                func deadFunc(foo: String = "****  You have died  ****") {
                    output(foo)
                }
                """,
            type: .void,
            category: .routines,
            children: [
                Symbol(
                    id: "<List>",
                    code: "foo: String = \"****  You have died  ****\"",
                    type: .list,
                    children: [
                        Symbol("foo", type: .string),
                        Symbol("\"****  You have died  ****\"", type: .string)
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
                        .atom(".REMARK"),
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
                .atom(".CNT")
            ])
        ]).process()
        
        let expected = Symbol(
            id: "remark",
            code: """
                /// The `remark` (REMARK) routine.
                func remark(len: TableElement = remark[0], cnt: Int = 0) {
                    output(cnt)
                }
                """,
            type: .void,
            category: .routines,
            children: [
                Symbol(
                    id: "<List>",
                    code: "len: TableElement = remark[0]",
                    type: .list,
                    children: [
                        Symbol("len", type: .tableElement),
                        Symbol(
                            "remark[0]",
                            type: .tableElement,
                            children: [
                                Symbol("remark", type: .array(.tableElement)),
                                Symbol("0", type: .int)
                            ]
                        )
                    ]
                ),
                Symbol(
                    id: "<List>",
                    code: "cnt: Int = 0",
                    type: .list,
                    children: [
                        Symbol("cnt", type: .int),
                        Symbol("0", type: .int)
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
    
}
