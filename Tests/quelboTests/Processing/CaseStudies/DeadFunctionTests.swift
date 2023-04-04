//
//  DeadFunctionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/8/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class DeadFunctionTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
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
            <GLOBAL WINNER 0>

            <OBJECT TROLL>
            <OBJECT LAMP>

            <ROOM SOUTH-TEMPLE>
            <ROOM TIMBER-ROOM>
            <ROOM TROLL-ROOM>

            <ROUTINE DEAD-FUNCTION ("OPTIONAL" (FOO <>) "AUX" M)
                 <COND (<VERB? WALK>
                    <COND (<AND <EQUAL? ,HERE ,TIMBER-ROOM>
                            <EQUAL? ,PRSO ,P?WEST>>
                           <TELL "You cannot enter in your condition." CR>)>)
                       (<VERB? BRIEF VERBOSE SUPER-BRIEF
                           VERSION ;AGAIN SAVE RESTORE QUIT RESTART>
                    <>)
                       (<VERB? ATTACK MUNG ALARM SWING>
                    <TELL "All such attacks are vain in your condition." CR>)
                       (<VERB? OPEN CLOSE EAT DRINK
                           INFLATE DEFLATE TURN BURN
                           TIE UNTIE RUB>
                    <TELL
            "Even such an action is beyond your capabilities." CR>)
                       (<VERB? WAIT>
                    <TELL "Might as well. You've got an eternity." CR>)
                       (<VERB? LAMP-ON>
                    <TELL "You need no light to guide you." CR>)
                       (<VERB? SCORE>
                    <TELL "You're dead! How can you think of your score?" CR>)
                       (<VERB? TAKE RUB>
                    <TELL "Your hand passes through its object." CR>)
                       (<VERB? DROP THROW INVENTORY>
                    <TELL "You have no possessions." CR>)
                       (<VERB? DIAGNOSE>
                    <TELL "You are dead." CR>)
                       (<VERB? LOOK>
                    <TELL "The room looks strange and unearthly">
                    <COND (<NOT <FIRST? ,HERE>>
                           <TELL ".">)
                          (T
                           <TELL " and objects appear indistinct.">)>
                    <CRLF>
                    <COND (<NOT <FSET? ,HERE ,ONBIT>>
                           <TELL
            "Although there is no light, the room seems dimly illuminated." CR>)>
                    <CRLF>
                    <>)
                       (<VERB? PRAY>
                    <COND (<EQUAL? ,HERE ,SOUTH-TEMPLE>
                           <FCLEAR ,LAMP ,INVISIBLE>
                           <PUTP ,WINNER ,P?ACTION 0>
                           ;<SETG GWIM-DISABLE <>>
                           <SETG ALWAYS-LIT <>>
                           <SETG DEAD <>>
                           <COND (<IN? ,TROLL ,TROLL-ROOM>
                              <SETG TROLL-FLAG <>>)>
                           <TELL
            "From the distance the sound of a lone trumpet is heard. The room
            becomes very bright and you feel disembodied. In a moment, the
            brightness fades and you find yourself rising as if from a long
            sleep, deep in the woods. In the distance you can faintly hear a
            songbird and the sounds of the forest." CR CR>
                           <GOTO ,FOREST-1>)
                          (T
                           <TELL "Your prayers are not heard." CR>)>)
                       (T
                    <TELL "You can't even do that." CR>
                    <SETG P-CONT <>>
                    <RFATAL>)>>
        """)
    }

    func testDeadFunction() throws {
        XCTAssertNoDifference(
            Game.routines.find("deadFunc"),
            Statement(
                id: "deadFunc",
                code: #"""
                    @discardableResult
                    /// The `deadFunc` (DEAD-FUNCTION) action routine.
                    func deadFunc(foo: Bool = false) throws -> Bool {
                        // var m: <Unknown>
                        if isParsedVerb("walk") {
                            if .and(
                                Globals.here.equals(Rooms.timberRoom),
                                Globals.parsedDirectObject.equals(west)
                            ) {
                                output("You cannot enter in your condition.")
                            }
                        } else if isParsedVerb(
                            "brief",
                            "verbose",
                            "superBrief",
                            "version",
                            "save",
                            "restore",
                            "quit",
                            "restart"
                        ) {
                            return false
                        } else if isParsedVerb("attack", "mung", "alarm", "swing") {
                            output("All such attacks are vain in your condition.")
                        } else if isParsedVerb(
                            "open",
                            "close",
                            "eat",
                            "drink",
                            "inflate",
                            "deflate",
                            "turn",
                            "burn",
                            "tie",
                            "untie",
                            "rub"
                        ) {
                            output("Even such an action is beyond your capabilities.")
                        } else if isParsedVerb("wait") {
                            output("Might as well. You've got an eternity.")
                        } else if isParsedVerb("lampOn") {
                            output("You need no light to guide you.")
                        } else if isParsedVerb("score") {
                            output("You're dead! How can you think of your score?")
                        } else if isParsedVerb("take", "rub") {
                            output("Your hand passes through its object.")
                        } else if isParsedVerb("drop", "throw", "inventory") {
                            output("You have no possessions.")
                        } else if isParsedVerb("diagnose") {
                            output("You are dead.")
                        } else if isParsedVerb("look") {
                            output("The room looks strange and unearthly")
                            if .isNot(Globals.here.firstChild) {
                                output(".")
                            } else {
                                output(" and objects appear indistinct.")
                            }
                            output("\n")
                            if .isNot(Globals.here.hasFlag(.isOn)) {
                                output("""
                                    Although there is no light, the room seems dimly \
                                    illuminated.
                                    """)
                            }
                            output("\n")
                            return false
                        } else if isParsedVerb("pray") {
                            if Globals.here.equals(Rooms.southTemple) {
                                Objects.lamp.isInvisible.set(false)
                                Globals.winner.action = 0
                                // <SETG GWIM-DISABLE false>
                                Globals.alwaysLit.set(to: false)
                                Globals.dead.set(to: false)
                                if Objects.troll.isIn(Rooms.trollRoom) {
                                    Globals.trollFlag.set(to: false)
                                }
                                output("""
                                    From the distance the sound of a lone trumpet is heard. The \
                                    room becomes very bright and you feel disembodied. In a \
                                    moment, the brightness fades and you find yourself rising as \
                                    if from a long sleep, deep in the woods. In the distance you \
                                    can faintly hear a songbird and the sounds of the forest.
                                    """)
                                try goto(rm: Rooms.forest1)
                            } else {
                                output("Your prayers are not heard.")
                            }
                        } else {
                            output("You can't even do that.")
                            pCont.set(to: false)
                            returnFatal()
                        }
                    }
                    """#,
                type: .booleanFalse,
                category: .routines,
                isActionRoutine: true,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }
}
