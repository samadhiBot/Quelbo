//
//  VLeapTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/19/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class VLeapTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        IsAccessibleTests().sharedSetUp()
        BufferPrintTests().sharedSetUp()
        NotHereTests().sharedSetUp()
        PerformTests().sharedSetUp()
        DoWalkTests().sharedSetUp()
        ShakeLoopTests().sharedSetUp()
        SearchListTests().sharedSetUp()
        DoSlTests().sharedSetUp()
        IsLitTests().sharedSetUp()
        IntTests().sharedSetUp()
        DescribeObjectTests().sharedSetUp()
        DescribeRoomTests().sharedSetUp()
        DescribeObjectsTests().sharedSetUp()
        IsYesTests().sharedSetup()
        FinishTests().sharedSetUp()
        JigsUpTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <GLOBAL JUMPLOSS
                <LTABLE 0
                       "You should have looked before you leaped."
                       "In the movies, your life would be passing before your eyes."
                       "Geronimo...">>
            <GLOBAL WHEEEEE
                <LTABLE 0 "Very good. Now you can go to the second grade."
                       "Are you enjoying yourself?"
                       "Wheeeeeeeeee!!!!!"
                       "Do you expect me to applaud?">>

            <ROUTINE V-SKIP ()
                 <TELL <PICK-ONE ,WHEEEEE> CR>>

            <ROUTINE V-LEAP ("AUX" TX S)
                 <COND (,PRSO
                    <COND (<IN? ,PRSO ,HERE>
                           <COND (<FSET? ,PRSO ,ACTORBIT>
                              <TELL
            "The " D ,PRSO " is too big to jump over." CR>)
                             (T
                              <V-SKIP>)>)
                          (T
                           <TELL "That would be a good trick." CR>)>)
                       (<SET TX <GETPT ,HERE ,P?DOWN>>
                    <SET S <PTSIZE .TX>>
                    <COND (<OR <EQUAL? .S 2> ;NEXIT
                                  <AND <EQUAL? .S 4> ;CEXIT
                            <NOT <VALUE <GETB .TX 1>>>>>
                           <TELL
            "This was not a very safe place to try jumping." CR>
                           <JIGS-UP <PICK-ONE ,JUMPLOSS>>)
                          %<COND (<==? ,ZORK-NUMBER 1>
                              '(<EQUAL? ,HERE ,UP-A-TREE>
                                    <TELL
            "In a feat of unaccustomed daring, you manage to land on your feet without
            killing yourself." CR CR>
                                    <DO-WALK ,P?DOWN>
                                    <RTRUE>))
                             (T '(<NULL-F> T))>
                          (T
                           <V-SKIP>)>)
                       (T
                    <V-SKIP>)>>
        """)
    }

    func testVLeap() throws {
        XCTAssertNoDifference(
            Game.routines.find("vLeap"),
            Statement(
                id: "vLeap",
                code: #"""
                    @discardableResult
                    /// The `vLeap` (V-LEAP) routine.
                    func vLeap() throws -> Bool {
                        var tx: Object?
                        var s = 0
                        if let Globals.parsedDirectObject {
                            if Globals.parsedDirectObject.isIn(Globals.here) {
                                if Globals.parsedDirectObject.hasFlag(.isActor) {
                                    output("The ")
                                    output(Globals.parsedDirectObject.description)
                                    output(" is too big to jump over.")
                                } else {
                                    try vSkip()
                                }
                            } else {
                                output("That would be a good trick.")
                            }
                        } else if _ = tx.set(to: Globals.here.down) {
                            s.set(to: tx.propertySize)
                            if .or(
                                s.equals(2),
                                .and(s.equals(4), .isNot(try tx.get(at: 1)))
                            ) {
                                output("This was not a very safe place to try jumping.")
                                try jigsUp(
                                    desc: try pickOne(frob: Globals.jumploss)
                                )
                            } else if Globals.here.equals(Rooms.upATree) {
                                output("""
                                    In a feat of unaccustomed daring, you manage to land on your \
                                    feet without killing yourself.
                                    """)
                                doWalk(dir: down)
                                return true
                            } else {
                                try vSkip()
                            }
                        } else {
                            try vSkip()
                        }
                    }
                    """#,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }
}
