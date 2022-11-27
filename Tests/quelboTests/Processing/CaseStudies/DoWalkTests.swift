//
//  DoWalkTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DoWalkTests: QuelboTests {
    override func setUp() {
        super.setUp()

        PerformTests().setUp()

        process("""
            <DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT>

            <ROUTINE DO-WALK (DIR)
                 <SETG P-WALK-DIR .DIR>
                 <PERFORM ,V?WALK .DIR>>

            <ROUTINE BARROW-FCN ()
                 <COND (<VERB? THROUGH>
                    <DO-WALK ,P?WEST>)>>
        """)
    }

    func testDoWalk() throws {
        XCTAssertNoDifference(
            Game.routines.find("doWalk"),
            Statement(
                id: "doWalk",
                code: """
                    @discardableResult
                    /// The `doWalk` (DO-WALK) routine.
                    func doWalk(dir: Any) -> Bool {
                        pWalkDir.set(to: dir)
                        return perform(a: walk, o: dir)
                    }
                    """,
                type: .bool,
                category: .routines,
                isCommittable: true
            )
        )
    }

    func testBarrowFunc() throws {
        XCTAssertNoDifference(
            Game.routines.find("barrowFunc"),
            Statement(
                id: "barrowFunc",
                code: """
                    /// The `barrowFunc` (BARROW-FCN) routine.
                    func barrowFunc() {
                        if isVerb(.through) {
                            doWalk(dir: west)
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true
            )
        )
    }
}
