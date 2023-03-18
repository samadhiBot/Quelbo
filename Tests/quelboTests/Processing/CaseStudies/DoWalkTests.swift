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

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        IsAccessibleTests().sharedSetUp()
        BufferPrintTests().sharedSetUp()
        NotHereTests().sharedSetUp()
        PerformTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <GLOBAL P-WALK-DIR <>>

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
                    func doWalk(dir: Object) -> Int? {
                        Global.pWalkDir.set(to: dir)
                        return perform(a: Verb.walk, o: dir)
                    }
                    """,
                type: .int.optional,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
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
                        if isParsedVerb(.through) {
                            doWalk(dir: west)
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
