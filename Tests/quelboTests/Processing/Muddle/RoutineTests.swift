//
//  RoutineTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/11/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RoutineTests: XCTestCase {
    func testProcessZeroParams() throws {
        var routine = Routine([
            .atom("BAG-OF-COINS-F"),
            .list([]),
            .commented(.atom("noop")),
        ])

        XCTAssertNoDifference(
            try routine.process().code,
            """
            /// The `bagOfCoinsFunc` (BAG-OF-COINS-F) routine.
            func bagOfCoinsFunc() -> Bool {
                // noop
            }
            """
        )
    }

    func testProcessOneParam() {
        var routine = Routine([
            .atom("WEST-HOUSE"),
            .list([
                .atom("RARG")
            ]),
            .commented(.atom("noop")),
        ])

        XCTAssertNoDifference(
            try routine.process().code,
            """
            /// The `westHouse` (WEST-HOUSE) routine.
            func westHouse(rarg: Int) -> Bool {
                // noop
            }
            """
        )
    }

    func testProcessWithAuxiliaryParams() {
        var routine = Routine([
            .atom("WINNING?"),
            .list([
                .atom("V"),
                .string("AUX"),
                .atom("VS"),
                .atom("PS")
            ]),
            .commented(.atom("noop")),
        ])

        XCTAssertNoDifference(
            try routine.process().code,
            """
            /// The `isWinning` (WINNING?) routine.
            func isWinning(v: Unknown) -> Bool {
                var vs: Unknown
                var ps: Unknown

                // noop
            }
            """
        )
    }

    func testProcessWithAuxiliaryParamsWithDefaultValues() {
        var routine = Routine([
            .atom("THIEF-VS-ADVENTURER"),
            .list([
                .atom("HERE?"),
                .string("AUX"),
                .atom("ROBBED?"),
                .list([
                    .atom("WINNER-ROBBED?"),
                    .bool(false)
                ])
            ]),
            .commented(.atom("noop")),
        ])

        XCTAssertNoDifference(
            try routine.process().code,
            """
            /// The `thiefVsAdventurer` (THIEF-VS-ADVENTURER) routine.
            func thiefVsAdventurer(isHere: Bool) -> Bool {
                var isRobbed: Bool
                var isWinnerRobbed: Bool = false

                // noop
            }
            """
        )
    }

    func testProcessWithOneOptionalParam() {
        var routine = Routine([
            .atom("BAT-D"),
            .list([
                .string("OPTIONAL"),
                .atom("FOO")
            ]),
            .commented(.atom("noop")),
        ])

        XCTAssertNoDifference(
            try routine.process().code,
            """
            /// The `batD` (BAT-D) routine.
            func batD(foo: Unknown? = nil) -> Bool {
                // noop
            }
            """
        )
    }

    func testProcessWithMultipleOptionalParam() {
        var routine = Routine([
            .atom("CONTRIVED"),
            .list([
                .string("OPTIONAL"),
                .atom("FOO"),
                .list([
                    .atom("BAR"),
                    .decimal(42)
                ])
            ]),
            .commented(.atom("noop")),
        ])

        XCTAssertNoDifference(
            try routine.process().code,
            """
            /// The `contrived` (CONTRIVED) routine.
            func contrived(foo: Unknown? = nil, bar: Int = 42) -> Bool {
                // noop
            }
            """
        )
    }

    func testProcessWithOneDefaultValueParam() {
        var routine = Routine([
            .atom("DEAD-FUNCTION"),
            .list([
                .string("OPTIONAL"),
                .list([
                    .atom("FOO"),
                    .bool(false)
                ]),
                .string("AUX"),
                .atom("M")
            ]),
            .commented(.atom("noop")),
        ])

        XCTAssertNoDifference(
            try routine.process().code,
            """
            /// The `deadFunc` (DEAD-FUNCTION) routine.
            func deadFunc(foo: Bool = false) -> Bool {
                var m: Unknown

                // noop
            }
            """
        )
    }

    // <ROUTINE REMARK (REMARK D W "AUX" (LEN <GET .REMARK 0>) (CNT 0) STR)

    func testProcessWithMultipleDefaultValueParam() {
        var routine = Routine([
            .atom("REMARK"),
            .list([
                .atom("REMARK"),
                .atom("D"),
                .atom("W"),
                .string("AUX"),
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
                .atom("STR")
            ]),
            .commented(.atom("noop")),
        ])

        XCTAssertNoDifference(
            try routine.process().code,
            """
            /// The `remark` (REMARK) routine.
            func remark(remark: Unknown, d: Unknown, w: Unknown) -> Bool {
                var len: Unknown = [quelbo.Token.atom("GET"), quelbo.Token.atom(".REMARK"), quelbo.Token.decimal(0)]
                var cnt: Int = 0
                var str: Unknown

                // noop
            }
            """
        )
    }

    // <ROUTINE THIEF-VS-ADVENTURER (HERE? "AUX" ROBBED? (WINNER-ROBBED? <>))

    // <ROUTINE ROBBER-FUNCTION ("OPTIONAL" (MODE <>) "AUX" (FLG <>) X N)

    // <ROUTINE I-LANTERN ("AUX" TICK (TBL <VALUE LAMP-TABLE>))

}
