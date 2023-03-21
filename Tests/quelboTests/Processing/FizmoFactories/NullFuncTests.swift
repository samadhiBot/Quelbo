//
//  NullFuncTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/13/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class NullFuncTests: QuelboTests {
    override func setUp() {
        super.setUp()

        process("""
            <SETG ZORK-NUMBER 2>

            <OBJECT MIRROR-1>
            <OBJECT MIRROR-2>

            <ROOM SANDY-CAVE>

            <ROUTINE NULL-F ("OPTIONAL" A1 A2) <RFALSE>>

            <ROUTINE ABRIDGED-CRETIN-FCN ()
                 <COND (<VERB? EXAMINE>
                    <COND %<COND (<==? ,ZORK-NUMBER 1>
                              '(<EQUAL? ,HERE <LOC ,MIRROR-1> <LOC ,MIRROR-2>>
                                    <TELL "Your image in the mirror looks tired." CR>))
                             (<==? ,ZORK-NUMBER 3>
                              '(,INVIS
                            <TELL "A good trick, as you are currently invisible." CR>))
                             (T
                              '(<NULL-F> <RTRUE>))>
                          (T
                           %<COND (<==? ,ZORK-NUMBER 3>
                               '<TELL "What you can see looks pretty much as usual, sorry to say." CR>)
                              (ELSE
                               '<TELL "That's difficult unless your eyes are prehensile." CR>)>)>)>>

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
    }

    func testNullFunc() throws {
        XCTAssertNoDifference(
            Game.routines.find("nullFunc"),
            Statement(
                id: "nullFunc",
                code: """
                    @discardableResult
                    /// The `nullFunc` (NULL-F) routine.
                    func nullFunc(a1: Any? = nil, a2: Any? = nil) -> Bool {
                        false
                    }
                    """,
                type: .bool,
                category: .routines
            )
        )
    }

    func testAbridgedCretinFunc() throws {
        XCTAssertNoDifference(
            Game.routines.find("abridgedCretinFunc"),
            Statement(
                id: "abridgedCretinFunc",
                code: """
                    @discardableResult
                    /// The `abridgedCretinFunc` (ABRIDGED-CRETIN-FCN) routine.
                    func abridgedCretinFunc() -> Bool {
                        if isParsedVerb(.examine) {
                            if nullFunc() {
                                return true
                            } else {
                                output("That's difficult unless your eyes are prehensile.")
                            }
                        }
                    }
                    """,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testAbridgedGroundFunc() throws {
        XCTAssertNoDifference(
            Game.routines.find("abridgedGroundFunc"),
            Statement(
                id: "abridgedGroundFunc",
                code: """
                    /// The `abridgedGroundFunc` (ABRIDGED-GROUND-FUNCTION) routine.
                    func abridgedGroundFunc() {
                        if isParsedVerb(.dig) {
                            output("The ground is too hard for digging here.")
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
