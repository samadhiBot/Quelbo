//
//  ItakeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/6/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class ItakeTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
    }

    func sharedSetUp(for zorkNumber: ZorkNumber = .zork1) {
        DescribeObjectTests().sharedSetUp(for: zorkNumber)

        process("""
            <GLOBAL DEAD <>>
            <GLOBAL FUMBLE-NUMBER 7>
            <GLOBAL FUMBLE-PROB 8>
            <GLOBAL LOAD-ALLOWED 100>
            <GLOBAL LOAD-MAX 100>
            <GLOBAL PLAYER <>>

            <GLOBAL YUKS
                <LTABLE
                 0
                 "A valiant attempt."
                 "You can't be serious."
                 ;"Not bloody likely."
                 "An interesting idea..."
                 "What a concept!">>

            <OBJECT TROPHY-CASE (FLAGS TRANSBIT CONTBIT NDESCBIT TRYTAKEBIT SEARCHBIT)>

            <ROUTINE CCOUNT (OBJ "AUX" (CNT 0) X)
                 <COND (<SET X <FIRST? .OBJ>>
                    <REPEAT ()
                        <COND (<NOT <FSET? .X ,WEARBIT>>
                               <SET CNT <+ .CNT 1>>)>
                        <COND (<NOT <SET X <NEXT? .X>>>
                               <RETURN>)>>)>
                 .CNT>

            <ROUTINE SCORE-OBJ (OBJ "AUX" TEMP)
                 <COND (<G? <SET TEMP <GETP .OBJ ,P?VALUE>> 0>
                    <SCORE-UPD .TEMP>
                    <PUTP .OBJ ,P?VALUE 0>)>>

            <ROUTINE WEIGHT (OBJ "AUX" CONT (WT 0))
                 <COND (<SET CONT <FIRST? .OBJ>>
                    <REPEAT ()
                        <COND (<AND <EQUAL? .OBJ ,PLAYER>
                                <FSET? .CONT ,WEARBIT>>
                               <SET WT <+ .WT 1>>)
                              (T
                               <SET WT <+ .WT <WEIGHT .CONT>>>)>
                        <COND (<NOT <SET CONT <NEXT? .CONT>>> <RETURN>)>>)>
                 <+ .WT <GETP .OBJ ,P?SIZE>>>

            <ROUTINE ITAKE ("OPTIONAL" (VB T) "AUX" CNT OBJ)
                 #DECL ((VB) <OR ATOM FALSE> (CNT) FIX (OBJ) OBJECT)
                 <COND %<COND (<==? ,ZORK-NUMBER 1>
                           '(,DEAD
                             <COND (.VB
                            <TELL
            "Your hand passes through its object." CR>)>
                             <RFALSE>))
                          (T
                           '(<NULL-F>
                         <RFALSE>))>
                       (<NOT <FSET? ,PRSO ,TAKEBIT>>
                    <COND (.VB
                           <TELL <PICK-ONE ,YUKS> CR>)>
                    <RFALSE>)
                       %<COND (<==? ,ZORK-NUMBER 2>
                           '(<AND <EQUAL? ,PRSO ,SPELL-VICTIM>
                                  <EQUAL? ,SPELL-USED ,W?FLOAT ,W?FREEZE>>
                             <COND (<EQUAL? ,SPELL-USED ,W?FLOAT>
                                    <TELL
            "You can't reach that. It's floating above your head." CR>)
                                   (T
                                    <TELL "It seems rooted to the spot." CR>)>
                             <RFALSE>))
                          (T
                           '(<NULL-F>
                         <RFALSE>))>
                       (<AND <FSET? <LOC ,PRSO> ,CONTBIT>
                         <NOT <FSET? <LOC ,PRSO> ,OPENBIT>>>
                    ;"Kludge for parser calling itake"
                    <RFALSE>)
                       (<AND <NOT <IN? <LOC ,PRSO> ,WINNER>>
                         <G? <+ <WEIGHT ,PRSO> <WEIGHT ,WINNER>> ,LOAD-ALLOWED>>
                    <COND (.VB
                           <TELL "Your load is too heavy">
                           <COND (<L? ,LOAD-ALLOWED ,LOAD-MAX>
                              <TELL ", especially in light of your condition.">)
                             (T
                              <TELL ".">)>
                           <CRLF>)>
                    <RFATAL>)
                       (<AND <VERB? TAKE>
                         <G? <SET CNT <CCOUNT ,WINNER>> ,FUMBLE-NUMBER>
                         <PROB <* .CNT ,FUMBLE-PROB>>>
                    <TELL
            "You're holding too many things already!" CR>
                    <RFALSE>)
                       (T
                    <MOVE ,PRSO ,WINNER>
                    <FCLEAR ,PRSO ,NDESCBIT>
                    <FSET ,PRSO ,TOUCHBIT>
                    %<COND (<==? ,ZORK-NUMBER 2>
                        '<COND (<EQUAL? ,SPELL? ,S-FILCH>
                                    <COND (<RIPOFF ,PRSO ,WIZARD-CASE>
                                       <TELL
            "When you touch the " D ,PRSO " it immediately disappears!" CR>
                                       <RFALSE>)>)>)
                           (T
                        '<NULL-F>)>
                    %<COND (<OR <==? ,ZORK-NUMBER 1>
                            <==? ,ZORK-NUMBER 2>>
                        '<SCORE-OBJ ,PRSO>)
                           (T
                        '<NULL-F>)>
                    <RTRUE>)>>
        """)
    }

    func testITakeZork1() throws {
        sharedSetUp(for: .zork1)

        XCTAssertNoDifference(
            Game.routines.find("itake"),
            Statement(
                id: "itake",
                code: #"""
                    @discardableResult
                    /// The `itake` (ITAKE) routine.
                    func itake(vb: Bool = true) throws -> Bool {
                        var cnt = 0
                        // var obj: <Unknown>
                        if Globals.dead {
                            if vb {
                                output("Your hand passes through its object.")
                            }
                            return false
                        } else if .isNot(Globals.parsedDirectObject.hasFlag(.isTakable)) {
                            if vb {
                                output(try pickOne(frob: Globals.yuks))
                            }
                            return false
                        } else if nullFunc() {
                            return false
                        } else if .and(
                            Globals.parsedDirectObject.parent.hasFlag(.isContainer),
                            .isNot(Globals.parsedDirectObject.parent.hasFlag(.isOpen))
                        ) {
                            // "Kludge for parser calling itake"
                            return false
                        } else if .and(
                            .isNot(Globals.parsedDirectObject.parent.isIn(Globals.winner)),
                            weight(obj: Globals.parsedDirectObject).add(weight(obj: Globals.winner)).isGreaterThan(Globals.loadAllowed)
                        ) {
                            if vb {
                                output("Your load is too heavy")
                                if Globals.loadAllowed.isLessThan(Globals.loadMax) {
                                    output(", especially in light of your condition.")
                                } else {
                                    output(".")
                                }
                                output("\n")
                            }
                            returnFatal()
                        } else if .and(
                            isParsedVerb(.take),
                            cnt.set(to: ccount(obj: Globals.winner)).isGreaterThan(Globals.fumbleNumber),
                            prob(isBase: cnt.multiply(Globals.fumbleProb))
                        ) {
                            output("You're holding too many things already!")
                            return false
                        } else {
                            parsedDirectObject.move(to: Globals.winner)
                            Globals.parsedDirectObject.omitDescription.set(false)
                            Globals.parsedDirectObject.hasBeenTouched.set(true)
                            nullFunc()
                            scoreObj(obj: Globals.parsedDirectObject)
                            return true
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
