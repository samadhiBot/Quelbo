//
//  RepeatTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RepeatTests: QuelboTests {
    let factory = Factories.Repeat.self
    let routineFactory = Factories.Routine.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "isFunnyReturn", type: .bool, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("REPEAT"))
    }

    func testRepeatFirstZilfExample() throws {
        let symbol = try routineFactory.init([
            .atom("TEST-REPEAT-1"),
            .list([
            ]),
            .form([
                .atom("TELL"),
                .string("START: ")
            ]),
            .form([
                .atom("REPEAT"),
                .list([
                    .atom("X")
                ]),
                .commented(
                    .string("X is not reinitialized between iterations. Default ACTIVATION created.")
                ),
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
                .commented(.string("Bare RETURN without ACTIVATION will exit BLOCK"))
            ]),
            .form([
                .atom("TELL"),
                .string("RETURN EXIT BLOCK"),
                .atom("CR"),
                .atom("CR")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "testRepeat1",
            code: """
                /// The `testRepeat1` (TEST-REPEAT-1) routine.
                func testRepeat1() {
                    output("START: ")
                    var x: Int = 0
                    while true {
                        // X is not reinitialized between iterations. Default ACTIVATION created.
                        x.set(to: x.add(1))
                        output(x)
                        output(" ")
                        if x.equals(3) {
                            break
                        }
                        // Bare RETURN without ACTIVATION will exit BLOCK
                    }
                    output("RETURN EXIT BLOCK")
                }
                """,
            type: .void,
            category: .routines
        ))
    }

    func testRepeatSecondZilfExample() throws {
        let symbol = try routineFactory.init([
            .atom("TEST-REPEAT-2"),
            .list([
            ]),
            .form([
                .atom("TELL"),
                .string("START: ")
            ]),
            .form([
                .atom("REPEAT"),
                .list([
                    .list([
                        .atom("X"),
                        .decimal(0)
                    ])
                ]),
                .commented(.string(
                    """
                    X is not reinitialized between iterations.
                    Default ACTIVATION created.
                    """
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
                .commented(.string(
                    """
                    RETURN with value but without
                    ACTIVATION will exit ROUTINE
                    (FUNNY-RETURN = TRUE)
                    """
                ))
            ]),
            .form([
                .atom("TELL"),
                .string("RETURN EXIT BLOCK"),
                .atom("CR"),
                .atom("CR")
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "testRepeat2",
            code: """
                @discardableResult
                /// The `testRepeat2` (TEST-REPEAT-2) routine.
                func testRepeat2() -> Bool {
                    output("START: ")
                    var x: Int = 0
                    while true {
                        // X is not reinitialized between iterations.
                        // Default ACTIVATION created.
                        x.set(to: x.add(1))
                        output(x)
                        output(" ")
                        if x.equals(3) {
                            if isFunnyReturn {
                                output("RETURN EXIT ROUTINE")
                            }
                            return true
                        }
                        // RETURN with value but without
                        // ACTIVATION will exit ROUTINE
                        // (FUNNY-RETURN = TRUE)
                    }
                    output("RETURN EXIT BLOCK")
                }
                """,
            type: .booleanTrue,
            category: .routines
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ], with: &localVariables).process()
        )
    }
}
