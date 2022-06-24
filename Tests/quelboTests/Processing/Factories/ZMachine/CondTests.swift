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
            Symbol(id: "bottles", type: .int, category: .routines),
            Symbol(id: "clearing", type: .object, category: .rooms),
            Symbol(id: "here", type: .object, category: .rooms),
            Symbol(id: "isFunnyReturn", type: .bool, category: .globals),
            Symbol(id: "isIn", type: .bool, category: .routines),
            Symbol(id: "mEnter", type: .int, category: .globals),
            Symbol(id: "thisIsIt", type: .bool, category: .routines),
            Symbol(id: "troll", type: .object, category: .objects),
            Symbol(id: "wonFlag", type: .bool, category: .globals),
            Symbol(id: "prsi", type: .object, category: .globals),
            Symbol(id: "openBit", type: .bool, category: .flags),
            Symbol(id: "vehBit", type: .bool, category: .flags),
            Symbol(id: "isOpenable", type: .bool, category: .routines),
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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
            if rarg.equals(mEnter) {
                output("Rarg equals mEnter")
            }
            """,
            type: .void
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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
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
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            #"""
                if isFunnyReturn {
                    output("RETURN EXIT ROUTINE")
                }
                """#,
                type: .void
        ))
    }

    func testASD() throws {
        let symbol = try factory.init([
            .list([
                .form([
                    .atom("OR"),
                    .form([
                        .atom("FSET?"),
                        .global("PRSI"),
                        .global("OPENBIT")
                    ]),
                    .form([
                        .atom("OPENABLE?"),
                        .global("PRSI")
                    ]),
                    .form([
                        .atom("FSET?"),
                        .global("PRSI"),
                        .global("VEHBIT")
                    ])
                ])
            ]),
            .list([
                .atom("T"),
                .form([
                    .atom("TELL"),
                    .string("You can't do that."),
                    .atom("CR")
                ]),
                .form([
                    .atom("RTRUE")
                ])
            ])
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            """
                if .or(
                    prsi.hasFlag(openBit),
                    isOpenable(),
                    prsi.hasFlag(vehBit)
                ) { } else {
                    output("You can't do that.")
                    return true
                }
                """,
            type: .void
        ))
    }
}
