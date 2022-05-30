//
//  AgainTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/24/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class AgainTests: QuelboTests {
    let factory = Factories.Again.self
    let routineFactory = Factories.Routine.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("AGAIN"))
    }

    func testIsAgainStatement() throws {
        let symbol = try factory.init([], with: types).process()

        XCTAssertTrue(symbol.isAgainStatement)
    }

    func testAgainRoutine1() throws {
        let symbol = try routineFactory.init([
            .atom("TEST-AGAIN-1"),
            .list([
                .string("AUX"),
                .atom("X")
            ]),
            .form([
                .atom("SET"),
                .atom("X"),
                .form([
                    .atom("+"),
                    .local("X"),
                    .decimal(1)
                ])
            ]),
            .form([
                .atom("TELL"),
                .atom("N"),
                .local("X"),
                .string(" ")
            ]),
            .form([
                .atom("COND"),
                .list([
                    .form([
                        .atom("=?"),
                        .local("X"),
                        .decimal(5)
                    ]),
                    .form([
                        .atom("RETURN")
                    ])
                ])
            ]),
            .form([
                .atom("AGAIN")
            ]),
            .commented(.string("Start routine again, X keeps value"))
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "testAgain1",
            code: """
                /// The `testAgain1` (TEST-AGAIN-1) routine.
                func testAgain1() {
                    var x: Int = 0
                    while true {
                        x.set(to: x.add(1))
                        output(x)
                        output(" ")
                        if x.equals(5) {
                            break
                        }
                        continue
                        /* Start routine again, X keeps value */
                    }
                }
                """,
            type: .void,
            category: .routines
        ))
    }

    func testAgainRoutine2() throws {
        let symbol = try routineFactory.init([
            .atom("TEST-AGAIN-2"),
            .list([
                .string("AUX"),
                .list([
                    .atom("X"),
                    .decimal(0)
                ])
            ]),
            .form([
                .atom("SET"),
                .atom("X"),
                .form([
                    .atom("+"),
                    .local("X"),
                    .decimal(1)
                ])
            ]),
            .form([
                .atom("TELL"),
                .atom("N"),
                .local("X"),
                .string(" ")
            ]),
            .form([
                .atom("COND"),
                .list([
                    .form([
                        .atom("=?"),
                        .local("X"),
                        .decimal(5)
                    ]),
                    .form([
                        .atom("RETURN")
                    ])
                ])
            ]),
            .commented(.string("Never reached")),
            .form([
                .atom("AGAIN")
            ]),
            .commented(.string("Start routine again, X reinitialize to 0"))
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "testAgain2",
            code: """
                /// The `testAgain2` (TEST-AGAIN-2) routine.
                func testAgain2() {
                    while true {
                        var x: Int = 0
                        x.set(to: x.add(1))
                        output(x)
                        output(" ")
                        if x.equals(5) {
                            break
                        }
                        /* Never reached */
                        continue
                        /* Start routine again, X reinitialize to 0 */
                    }
                }
                """,
            type: .void,
            category: .routines
        ))
    }

    func testAgainRoutine3() throws {
        let symbol = try routineFactory.init([
            .atom("TEST-AGAIN-3"),
            .list([
            ]),
            .form([
                .atom("BIND"),
                .atom("ACT1"),
                .list([
                    .list([
                        .atom("X"),
                        .decimal(0)
                    ])
                ]),
                .form([
                    .atom("SET"),
                    .atom("X"),
                    .form([
                        .atom("+"),
                        .local("X"),
                        .decimal(1)
                    ])
                ]),
                .form([
                    .atom("TELL"),
                    .atom("N"),
                    .local("X"),
                    .string(" ")
                ]),
                .form([
                    .atom("COND"),
                    .list([
                        .form([
                            .atom("=?"),
                            .local("X"),
                            .decimal(5)
                        ]),
                        .form([
                            .atom("RETURN")
                        ])
                    ])
                ]),
                .form([
                    .atom("AGAIN"),
                    .local("ACT1")
                ]),
                .commented(.string("Start block again from ACT1,"))
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "testAgain3",
            code: """
                /// The `testAgain3` (TEST-AGAIN-3) routine.
                func testAgain3() {
                    var x: Int = 0
                    act1: while true {
                        x.set(to: x.add(1))
                        output(x)
                        output(" ")
                        if x.equals(5) {
                            break
                        }
                        continue act1
                        /* Start block again from ACT1, */
                    }
                }
                """,
            type: .void,
            category: .routines
        ))
    }

    func testAgainRoutine4() throws {
        let symbol = try routineFactory.init([
            .atom("TEST-AGAIN-4"),
            .list([
            ]),
            .form([
                .atom("PROG"),
                .list([
                    .list([
                        .atom("X"),
                        .decimal(0)
                    ])
                ]),
                .commented(.string("PROG generates default activation")),
                .form([
                    .atom("SET"),
                    .atom("X"),
                    .form([
                        .atom("+"),
                        .local("X"),
                        .decimal(1)
                    ])
                ]),
                .form([
                    .atom("TELL"),
                    .atom("N"),
                    .local("X"),
                    .string(" ")
                ]),
                .form([
                    .atom("COND"),
                    .list([
                        .form([
                            .atom("=?"),
                            .local("X"),
                            .decimal(5)
                        ]),
                        .form([
                            .atom("RETURN")
                        ])
                    ])
                ]),
                .form([
                    .atom("AGAIN")
                ]),
                .commented(.string("Start block again from PROG,"))
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "testAgain4",
            code: """
                /// The `testAgain4` (TEST-AGAIN-4) routine.
                func testAgain4() {
                    var x: Int = 0
                    while true {
                        /* PROG generates default activation */
                        x.set(to: x.add(1))
                        output(x)
                        output(" ")
                        if x.equals(5) {
                            break
                        }
                        continue
                        /* Start block again from PROG, */
                    }
                }
                """,
            type: .void,
            category: .routines
        ))
    }
}
