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
                payload: .init(
                    parameters: [
                        Instance(Statement(id: "n", type: .int))
                    ]
                ),
                category: .routines,
                isCommittable: true
            ),
            .statement(
                id: "isOpenable",
                code: "",
                type: .bool,
                category: .routines,
                isCommittable: true
            ),
            .statement(
                id: "thisIsIt",
                code: "",
                type: .bool,
                payload: .init(
                    parameters: [
                        Instance(Statement(id: "object", type: .object))
                    ]
                ),
                category: .routines,
                isCommittable: true
            ),
            .variable(id: "clearing", type: .object, category: .rooms),
            .variable(id: "here", type: .object, category: .rooms),
            .variable(id: "isFunnyReturn", type: .bool, category: .globals),
            .variable(id: "mEnter", type: .int, category: .globals),
            .variable(id: "openBit", type: .bool, category: .flags),
            .variable(id: "troll", type: .object, category: .objects),
            .variable(id: "vehBit", type: .bool, category: .flags),
            .variable(id: "wonFlag", type: .bool, category: .globals),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("COND", type: .zCode))
    }

    func testSingleIfCondition() throws {
        let symbol = process(
            """
                <COND (<EQUAL? .RARG ,M-ENTER>
                    <TELL "You are in a dark and damp cellar.">)>
            """,
            type: .zCode,
            with: [Statement(id: "rarg", type: .int)]
        )

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if rarg.equals(Globals.mEnter) {
                    output("You are in a dark and damp cellar.")
                }
                """,
            type: .void,
            returnHandling: .passthrough
        ))
    }

    func testMultipleIfElseIfCondition() throws {
        let symbol = process(
            """
                <COND
                    (<=? .SWITCH 1>
                        <TELL "Statement SWITCH = 1" CR>)
                    (<=? .SWITCH 2>
                        <TELL "Statement SWITCH = 2" CR>)
                    (<=? .SWITCH 3>
                        <TELL "Statement SWITCH = 3" CR>)
                    (T
                        <TELL "Statement SWITCH not in (1 2 3)" CR>)
                >
            """,
            type: .zCode,
            with: [Statement(id: "switch", type: .int)]
        )

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if switch.equals(1) {
                    output("Statement SWITCH = 1")
                } else if switch.equals(2) {
                    output("Statement SWITCH = 2")
                } else if switch.equals(3) {
                    output("Statement SWITCH = 3")
                } else {
                    output("Statement SWITCH not in (1 2 3)")
                }
                """,
            type: .void,
            returnHandling: .passthrough
        ))
    }

    func testSingleIfConditionImplicitReturnable() throws {
        let symbol = process(
            """
                <COND (<EQUAL? .RARG ,M-ENTER> <SET RARG .OTHER>)>
            """,
            type: .zCode,
            with: [
                Statement(id: "rarg", type: .int),
                Statement(id: "other", type: .int)
            ]
        )

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if rarg.equals(Globals.mEnter) {
                    rarg.set(to: other)
                }
                """,
            type: .void,
            returnHandling: .passthrough
        ))
    }


    func testAtomPredicate() throws {
        let symbol = try factory.init([
            .list([
                .global(.atom("WON-FLAG")),
                .form([
                    .atom("TELL"),
                    .string(" A secret path leads southwest into the forest.")
                ])
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if Globals.wonFlag {
                    output(" A secret path leads southwest into the forest.")
                }
                """,
            type: .void,
            returnHandling: .passthrough
        ))
    }

    func testTruePredicate()
    throws {
        let symbol = process(
            """
                <COND
                    (<EQUAL? ,HERE ,CLEARING> "The grating opens.")
                    (T "The grating opens to reveal trees above you.")>
            """,
            type: .zCode
        )

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if Rooms.here.equals(Rooms.clearing) {
                    return "The grating opens."
                } else {
                    return "The grating opens to reveal trees above you."
                }
                """,
            type: .string,
            returnHandling: .passthrough
        ))
    }

    func testElsePredicate() throws {
        localVariables.append(.init(id: "n", type: .int))

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
            returnHandling: .passthrough
        ))
    }

    func testBooleanPredicate() throws {
        let symbol = try factory.init([
            .list([
                .global(.atom("FUNNY-RETURN?")),
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
                if Globals.isFunnyReturn {
                    output("RETURN EXIT ROUTINE")
                }
                """#,
            type: .void,
            returnHandling: .passthrough
        ))
    }

    func testOrNothingElse() throws {
        let symbol = process(
            """
                 <COND (<OR <FSET? ,PRSI ,OPENBIT>
                        <OPENABLE? ,PRSI>
                        <FSET? ,PRSI ,VEHBIT>>)
                       (T
                    <TELL "You can't do that." CR>
                    <RTRUE>)>
            """,
            type: .zCode
        )

        XCTAssertNoDifference(symbol, .statement(
            code: """
                if .or(
                    Globals.parsedIndirectObject?.hasFlag(.openBit),
                    isOpenable(),
                    Globals.parsedIndirectObject?.hasFlag(.vehBit)
                ) {
                    // do nothing
                } else {
                    output("You can't do that.")
                    return true
                }
                """,
            type: .booleanTrue,
            returnHandling: .passthrough
        ))
    }

    func testEvalCondition() throws {
        let symbol = process("""
            <SETG ZORK-NUMBER 1>

            <ROUTINE COND-EVAL
                %<COND (<==? ,ZORK-NUMBER 1> '<TELL "Welcome to Zork 1">)
                    (<==? ,ZORK-NUMBER 2> '<TELL "Welcome to Zork 2">)
                    (T '<TELL "Welcome to Zork 3">)>>
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "condEval",
            code: """
                /// The `condEval` (COND-EVAL) routine.
                func condEval() {
                    output("Welcome to Zork 1")
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))
    }
}
