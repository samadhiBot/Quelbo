//
//  CondTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class CondTests: QuelboTests {
    let factory = Factories.Cond.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol("bottles", type: .int, category: .routines),
            Symbol("clearing", type: .object, category: .rooms),
            Symbol("here", type: .object, category: .rooms),
            Symbol("isFunnyReturn", type: .bool, category: .globals),
            Symbol("isIn", type: .bool, category: .routines),
            Symbol("mEnter", type: .int, category: .globals),
            Symbol("thisIsIt", type: .bool, category: .routines),
            Symbol("troll", type: .object, category: .objects),
            Symbol("wonFlag", type: .bool, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("COND"))
    }

    func testSingleCondition() throws {
        let symbol = try factory.init([
            .list([
                .form([
                    .atom("EQUAL?"),
                    .local("RARG"),
                    .global("M-ENTER")
                ]),
                .form([
                    .atom("PRINT"),
                    .string("Rarg equals mEnter")
                ])
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
            if rarg.equals(mEnter) {
                output("Rarg equals mEnter")
            }
            """,
            type: .void,
            children: [
                Symbol(
                    """
                        [
                            rarg.equals(mEnter),
                            output("Rarg equals mEnter"),
                        ]
                        """,
                    type: .array(.bool),
                    children: [
                        Symbol(
                            "rarg.equals(mEnter)",
                            type: .bool,
                            children: [
                                Symbol("rarg", type: .int),
                                Symbol("mEnter", type: .int, category: .globals),
                            ]
                        ),
                        Symbol(
                            "output(\"Rarg equals mEnter\")",
                            type: .void,
                            children: [
                                Symbol("\"Rarg equals mEnter\"", type: .string, meta: [.isLiteral]),
                            ]
                        )
                    ]
                )
            ]
        ))
    }

    func testDoubleCondition() throws {
        let symbol = try factory.init([
            .list([
                .form([
                    .atom("EQUAL?"),
                    .local("RARG"),
                    .global("M-ENTER")
                ]),
                .form([
                    .atom("PRINT"),
                    .string("Rarg equals mEnter")
                ])
            ]),
            .list([
                .form([
                    .atom("IN?"),
                    .global("TROLL"),
                    .global("HERE")
                ]),
                .form([
                    .atom("THIS-IS-IT"),
                    .global("TROLL")
                ])
            ]),
        ], with: types).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            """
                if rarg.equals(mEnter) {
                    output("Rarg equals mEnter")
                } else if troll.isIn(here) {
                    thisIsIt()
                }
                """,
            type: .void
        ))
    }

    func testAtomPredicate() throws {
        let symbol = try factory.init([
            .list([
                .global("WON-FLAG"),
                .form([
                    .atom("TELL"),
                    .string(" A secret path leads southwest into the forest.")
                ])
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            """
                if wonFlag {
                    output(" A secret path leads southwest into the forest.")
                }
                """,
            type: .void
        ))
    }

    func testTruePredicate() throws {
        let symbol = try factory.init([
            .list([
                .form([
                    .atom("EQUAL?"),
                    .global("HERE"),
                    .global("CLEARING")
                ]),
                .string("The grating opens.")
            ]),
            .list([
                .atom("T"),
                .string("The grating opens to reveal trees above you.")
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            """
                if here.equals(clearing) {
                    "The grating opens."
                } else {
                    "The grating opens to reveal trees above you."
                }
                """,
            type: .void
        ))
    }

    func testElsePredicate() throws {
        let symbol = try factory.init([
            .list([
                .form([
                    .atom("DLESS?"),
                    .atom("N"),
                    .decimal(1)
                ]),
                .form([
                    .atom("PRINTR"),
                    .string("No more bottles of beer on the wall!")
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
                    .string("""
                         of beer on the wall!
                        """)
                ])
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            #"""
                if n.decrement().isLessThan(1) {
                    output("No more bottles of beer on the wall!")
                    output("\n")
                } else {
                    bottles()
                    output(" of beer on the wall!")
                }
                """#,
            type: .void
        ))
    }

    func testBooleanPredicate() throws {
        let symbol = try factory.init([
            .list([
                .global("FUNNY-RETURN?"),
                .form([
                    .atom("TELL"),
                    .string("RETURN EXIT ROUTINE"),
                    .atom("CR"),
                    .atom("CR")
                ])
            ])
        ], with: types).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            #"""
                if isFunnyReturn {
                    output("RETURN EXIT ROUTINE")
                }
                """#,
            type: .void
        ))
    }
}
