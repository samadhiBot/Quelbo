//
//  ConditionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ConditionTests: QuelboTests {
    let factory = Factories.Condition.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .statement(
                id: "bottles",
                code: "",
                type: .int,
                parameters: [
                    Instance(Variable(id: "n", type: .int))
                ],
                category: .routines
            ),
            .statement(
                id: "isOpenable",
                code: "",
                type: .bool,
                category: .routines
            ),
            .statement(
                id: "thisIsIt",
                code: "",
                type: .bool,
                parameters: [
                    Instance(Variable(id: "object", type: .object))
                ],
                category: .routines
            ),
            .variable(id: "clearing", type: .object, category: .rooms),
            .variable(id: "here", type: .object, category: .rooms),
            .variable(id: "isFunnyReturn", type: .bool, category: .globals),
            .variable(id: "mEnter", type: .int, category: .globals),
            .variable(id: "openBit", type: .bool, category: .flags),
            .variable(id: "prsi", type: .object, category: .globals),
            .variable(id: "troll", type: .object, category: .objects),
            .variable(id: "vehBit", type: .bool, category: .flags),
            .variable(id: "wonFlag", type: .bool, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("COND"))
    }

    func testSingleCondition() throws {
        localVariables.append(Variable(id: "rarg", type: .int))

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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if rarg.equals(mEnter) {
                    output("Rarg equals mEnter")
                }
                """,
            type: .void,
            suppressesReturns: true
        ))
    }

    func testDoubleCondition() throws {
        localVariables.append(Variable(id: "rarg", type: .int))

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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if rarg.equals(mEnter) {
                    output("Rarg equals mEnter")
                } else if troll.isIn(here) {
                    thisIsIt(object: troll)
                }
                """,
            type: .bool,
            suppressesReturns: true
        ))
    }

    func testSingleConditionImplicitReturnable() throws {
        localVariables.append(contentsOf: [
            Variable(id: "rarg", type: .int),
            Variable(id: "other", type: .int)
        ])

        let symbol = try factory.init([
            .list([
                .form([
                    .atom("EQUAL?"),
                    .local("RARG"),
                    .global("M-ENTER")
                ]),
                .form([
                    .atom("SET"),
                    .local("RARG"),
                    .local("OTHER")
                ])
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if rarg.equals(mEnter) {
                    rarg.set(to: other)
                }
                """,
            type: .int,
            suppressesReturns: true
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if wonFlag {
                    output(" A secret path leads southwest into the forest.")
                }
                """,
            type: .void,
            suppressesReturns: true
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
            if here.equals(clearing) {
                return "The grating opens."
            } else {
                return "The grating opens to reveal trees above you."
            }
            """,
            type: .string,
            suppressesReturns: true
        ))
    }

    func testElsePredicate() throws {
        localVariables.append(Variable(id: "n", type: .int))

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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"""
                if n.decrement().isLessThan(1) {
                    output("No more bottles of beer on the wall!")
                    output("\n")
                } else {
                    bottles(n: n)
                    output(" of beer on the wall!")
                }
                """#,
            type: .void,
            suppressesReturns: true
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: #"""
                if isFunnyReturn {
                    output("RETURN EXIT ROUTINE")
                }
                """#,
                type: .void,
            suppressesReturns: true
        ))
    }

    func testOrNothingElse() throws {
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
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if .or(
                    prsi.hasFlag(openBit),
                    isOpenable(),
                    prsi.hasFlag(vehBit)
                ) {

                } else {
                    output("You can't do that.")
                    return true
                }
                """,
            type: .booleanTrue,
            suppressesReturns: true
        ))
    }
}
