//
//  BindTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/25/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class BindTests: QuelboTests {
    let factory = Factories.Bind.self
    let routineFactory = Factories.Routine.self

    override func setUp() {
        super.setUp()

        Game.commit([
            Symbol(
                id: "isFunnyReturn",
                code: "isFunnyReturn",
                type: .bool,
                category: .globals
            ),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("BIND"))
    }

    func testBindRoutine1() throws {
        let symbol = try routineFactory.init([
            .atom("TEST-BIND-1"),
            .list([
                .string("AUX"),
                .atom("X")
            ]),
            .form([
                .atom("TELL"),
                .string("START ")
            ]),
            .form([
                .atom("SET"),
                .atom("X"),
                .decimal(1)
            ]),
            .form([
                .atom("BIND"),
                .list([
                    .atom("X")
                ]),
                .form([
                    .atom("SET"),
                    .atom("X"),
                    .decimal(2)
                ]),
                .form([
                    .atom("TELL"),
                    .atom("N"),
                    .local("X"),
                    .string(" ")
                ]),
                .commented(.string("--> 2 (Inner X)"))
            ]),
            .form([
                .atom("TELL"),
                .atom("N"),
                .local("X"),
                .string(" ")
            ]),
            .commented(.string("--> 1 (Outer X)")),
            .form([
                .atom("TELL"),
                .string("END"),
                .atom("CR")
            ])
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "testBind1",
            code: """
                /// The `testBind1` (TEST-BIND-1) routine.
                func testBind1() {
                    var x: Int = 0
                    output("START ")
                    x.set(to: 1)
                    do {
                        var x: Int = 0
                        x.set(to: 2)
                        output(x)
                        output(" ")
                        /* --> 2 (Inner X) */
                    }
                    output(x)
                    output(" ")
                    /* --> 1 (Outer X) */
                    output("END")
                }
                """,
            type: .void,
            category: .routines,
            meta: [.blockType(.blockWithActivation("act_1a3f"))]
        ))
    }

    func testBindRoutine2() throws {
        let symbol = try routineFactory.init([
            .atom("TEST-BIND-2"),
            .list([
            ]),
            .form([
                .atom("TELL"),
                .string("START ")
            ]),
            .form([
                .atom("BIND"),
                .list([
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
                            .decimal(3)
                        ]),
                        .form([
                            .atom("RETURN")
                        ])
                    ])
                ]),
                .commented(.string("--> exit routine")),
                .form([
                    .atom("AGAIN")
                ]),
                .commented(.string("--> top of routine"))
            ]),
            .form([
                .atom("TELL"),
                .string("END"),
                .atom("CR")
            ]),
            .commented(.string("Never reached"))
        ], with: &registry).process()

        // "START 1 START 2 START 3 "
        XCTAssertNoDifference(symbol, Symbol(
            id: "testBind2",
            code: """
                /// The `testBind2` (TEST-BIND-2) routine.
                func testBind2() {
                    var x: Int = 0
                    act_6ccc: while true {
                        output("START ")
                        do {
                            x.set(to: x.add(1))
                            output(x)
                            output(" ")
                            if x.equals(3) {
                                break act_6ccc
                            }
                            /* --> exit routine */
                            continue
                            /* --> top of routine */
                        }
                        output("END")
                        /* Never reached */
                    }
                }
                """,
            type: .void,
            category: .routines,
            meta: [.blockType(.blockWithActivation("act_6ccc"))]
        ))
    }
}
