//
//  AbridgedCretinFuncTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/18/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class AbridgedCretinFuncTests: QuelboTests {
    func testAbridgedCretinFuncZork1() throws {
        process("""
            <SETG ZORK-NUMBER 1>

            <GLOBAL HERE 0>

            <OBJECT MIRROR-1>
            <OBJECT MIRROR-2>

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
        """)

        XCTAssertNoDifference(
            Game.routines.find("abridgedCretinFunc"),
            Statement(
                id: "abridgedCretinFunc",
                code: """
                    /// The `abridgedCretinFunc` (ABRIDGED-CRETIN-FCN) routine.
                    func abridgedCretinFunc() {
                        if isParsedVerb(.examine) {
                            if Globals.here.equals(
                                Objects.mirror1.parent,
                                Objects.mirror2.parent
                            ) {
                                output("Your image in the mirror looks tired.")
                            } else {
                                output("That's difficult unless your eyes are prehensile.")
                            }
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

    func testAbridgedCretinFuncZork2() throws {
        process("""
            <SETG ZORK-NUMBER 2>

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
        """)

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

    func testAbridgedCretinFuncZork3() throws {
        process("""
            <SETG INVIS <>>
            <SETG ZORK-NUMBER 3>

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
        """)

        XCTAssertNoDifference(
            Game.routines.find("abridgedCretinFunc"),
            Statement(
                id: "abridgedCretinFunc",
                code: """
                    /// The `abridgedCretinFunc` (ABRIDGED-CRETIN-FCN) routine.
                    func abridgedCretinFunc() {
                        if isParsedVerb(.examine) {
                            if Globals.invis {
                                output("A good trick, as you are currently invisible.")
                            } else {
                                output("What you can see looks pretty much as usual, sorry to say.")
                            }
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
