//
//  AbridgedGroundFuncTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class AbridgedGroundFuncTests: QuelboTests {
    func testAbridgedGroundFuncZork1() throws {
        process("""
            <SETG ZORK-NUMBER 1>

            <ROOM SANDY-CAVE>

            <ROUTINE ABRIDGED-SAND-FUNCTION ()
                <TELL "You can see a scarab here in the sand." CR>>

            <ROUTINE ABRIDGED-GROUND-FUNCTION ()
                <COND
                    %<COND
                        (<==? ,ZORK-NUMBER 1> '(<EQUAL? ,HERE ,SANDY-CAVE> <ABRIDGED-SAND-FUNCTION>))
                        (T '(<RFALSE>))
                    >
                   (<VERB? DIG> <TELL "The ground is too hard for digging here." CR>)
               >
            >
        """)

        XCTAssertNoDifference(
            Game.routines.find("abridgedGroundFunc"),
            Statement(
                id: "abridgedGroundFunc",
                code: """
                    /// The `abridgedGroundFunc` (ABRIDGED-GROUND-FUNCTION) routine.
                    func abridgedGroundFunc() {
                        if here.equals(sandyCave) {
                            abridgedSandFunc()
                        } else if isVerb(.dig) {
                            output("The ground is too hard for digging here.")
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true
            )
        )
    }

    func testAbridgedGroundFuncZork2() throws {
        process("""
            <SETG ZORK-NUMBER 2>

            ;"Token processing succeeds without the presence of the
              SANDY-CAVE room or the ABRIDGED-SAND-FUNCTION."

            <ROUTINE ABRIDGED-GROUND-FUNCTION ()
                <COND
                    %<COND
                        (<==? ,ZORK-NUMBER 1> '(<EQUAL? ,HERE ,SANDY-CAVE> <ABRIDGED-SAND-FUNCTION>))
                        (T '(<RFALSE>))
                    >
                   (<VERB? DIG> <TELL "The ground is too hard for digging here." CR>)
               >
            >
        """)

        XCTAssertNoDifference(
            Game.routines.find("abridgedGroundFunc"),
            Statement(
                id: "abridgedGroundFunc",
                code: """
                    /// The `abridgedGroundFunc` (ABRIDGED-GROUND-FUNCTION) routine.
                    func abridgedGroundFunc() {
                        if isVerb(.dig) {
                            output("The ground is too hard for digging here.")
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
