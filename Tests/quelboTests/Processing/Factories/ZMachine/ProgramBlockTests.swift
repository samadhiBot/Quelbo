//
//  ProgramBlockTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ProgramBlockTests: QuelboTests {
    let factory = Factories.ProgramBlock.self
    let routineFactory = Factories.Routine.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(
                id: "isFunnyReturn",
                code: "let isFunnyReturn: Bool = false",
                type: .bool,
                category: .globals
            ),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("PROG"))
    }

    func testProgRoutine1() throws {
        let symbol = try routineFactory.init([
            .atom("TEST-PROG-1"),
            .list([
                .string("AUX"),
                .atom("X")
            ]),
            .form([
                .atom("SET"),
                .atom("X"),
                .decimal(2)
            ]),
            .form([
                .atom("TELL"),
                .string("START: ")
            ]),
            .form([
                .atom("PROG"),
                .list([
                    .atom("X")
                ]),
                .form([
                    .atom("SET"),
                    .atom("X"),
                    .decimal(1)
                ]),
                .form([
                    .atom("TELL"),
                    .atom("N"),
                    .local("X"),
                    .string(" ")
                ]),
                .commented(.string("Inner X"))
            ]),
            .form([
                .atom("TELL"),
                .atom("N"),
                .local("X")
            ]),
            .commented(.string("Outer X")),
            .form([
                .atom("TELL"),
                .string(" END"),
                .atom("CR"),
                .atom("CR")
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "testProg1",
            code: """
                /// The `testProg1` (TEST-PROG-1) routine.
                func testProg1() {
                    var x: Int = 0
                    x.set(to: 2)
                    output("START: ")
                    do {
                        var x: Int = 0
                        x.set(to: 1)
                        output(x)
                        output(" ")
                        /* Inner X */
                    }
                    output(x)
                    /* Outer X */
                    output(" END")
                }
                """,
            type: .void,
            category: .routines
        ))
    }

    func testProgRoutine2() throws {
        let symbol = try routineFactory.init([
            .atom("TEST-PROG-2"),
            .list([
            ]),
            .form([
                .atom("TELL"),
                .string("START: ")
            ]),
            .form([
                .atom("PROG"),
                .list([
                    .atom("X")
                ]),
                .commented(.string(
                    "X is not reinitialized between iterations. Default ACTIVATION created."
                )),
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
                            .decimal(3)
                        ]),
                        .form([
                            .atom("RETURN")
                        ])
                    ])
                ]),
                .commented(.string("Bare RETURN without ACTIVATION will exit BLOCK")),
                .form([
                    .atom("AGAIN")
                ]),
                .commented(.string("AGAIN without ACTIVATION will redo BLOCK"))
            ]),
            .form([
                .atom("TELL"),
                .string("RETURN EXIT BLOCK"),
                .atom("CR"),
                .atom("CR")
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "testProg2",
            code: """
                /// The `testProg2` (TEST-PROG-2) routine.
                func testProg2() {
                    output("START: ")
                    var x: Int = 0
                    while true {
                        /* X is not reinitialized between iterations. Default ACTIVATION created. */
                        x.set(to: x.add(1))
                        output(x)
                        output(" ")
                        if x.equals(3) {
                            break
                        }
                        /* Bare RETURN without ACTIVATION will exit BLOCK */
                        continue
                        /* AGAIN without ACTIVATION will redo BLOCK */
                    }
                    output("RETURN EXIT BLOCK")
                }
                """,
            type: .void,
            category: .routines
        ))
    }

    func testProgRoutine3() throws {
        let symbol = try routineFactory.init([
            .atom("TEST-PROG-3"),
            .list([
            ]),
            .form([
                .atom("TELL"),
                .string("START: ")
            ]),
            .form([
                .atom("PROG"),
                .list([
                    .list([
                        .atom("X"),
                        .decimal(0)
                    ])
                ]),
                .commented(.string("X is not reinitialized between iterations. Default ACTIVATION created.")),
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
                            .decimal(3)
                        ]),
                        .form([
                            .atom("COND"),
                            .list([
                                .global("FUNNY-RETURN?"),
                                .form([
                                    .atom("TELL"),
                                    .string("RETURN EXIT ROUTINE"),
                                    .atom("CR"),
                                    .atom("CR")
                                ])
                            ])
                        ]),
                        .form([
                            .atom("RETURN"),
                            .atom("T")
                        ])
                    ])
                ]),
                .commented(.string("RETURN with value but without ACTIVATION will exit ROUTINE (FUNNY-RETURN = TRUE)")),
                .form([
                    .atom("AGAIN")
                ]),
                .commented(.string("AGAIN without ACTIVATION will redo BLOCK"))
            ]),
            .form([
                .atom("TELL"),
                .string("RETURN EXIT BLOCK"),
                .atom("CR"),
                .atom("CR")
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "testProg3",
            code: """
                @discardableResult
                /// The `testProg3` (TEST-PROG-3) routine.
                func testProg3() -> Bool {
                    output("START: ")
                    var x: Int = 0
                    while true {
                        /* X is not reinitialized between iterations. Default ACTIVATION created. */
                        x.set(to: x.add(1))
                        output(x)
                        output(" ")
                        if x.equals(3) {
                            if isFunnyReturn {
                                output("RETURN EXIT ROUTINE")
                            }
                            return true
                        }
                        /* RETURN with value but without ACTIVATION will exit ROUTINE (FUNNY-RETURN = TRUE) */
                        continue
                        /* AGAIN without ACTIVATION will redo BLOCK */
                    }
                    output("RETURN EXIT BLOCK")
                }
                """,
            type: .bool,
            category: .routines
        ))
    }
}
