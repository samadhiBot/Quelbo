//
//  FinishTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/11/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class FinishTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        DescribeObjectTests().sharedSetUp()
        DescribeRoomTests().sharedSetUp()
        DescribeObjectsTests().sharedSetUp()
        IsYesTests().sharedSetup()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <GLOBAL MOVES 0>
            <GLOBAL P-INBUF <ITABLE 120 (BYTE LENGTH) 0> ;<ITABLE BYTE 60>>
            <GLOBAL P-LEXV <ITABLE 59 (LEXV) 0 #BYTE 0 #BYTE 0> ;<ITABLE BYTE 120>>
            <GLOBAL SCORE 0>

            <SYNTAX QUIT = V-QUIT>
            <SYNTAX RESTART = V-RESTART>
            <SYNTAX RESTORE = V-RESTORE>

            <ROUTINE V-FIRST-LOOK ()
                 <COND (<DESCRIBE-ROOM>
                    <COND (<NOT ,SUPER-BRIEF>
                           <DESCRIBE-OBJECTS>)>)>>

            <ROUTINE V-SCORE ("OPTIONAL" (ASK? T))
                 #DECL ((ASK?) <OR ATOM FALSE>)
                 <TELL "Your score is ">
                 <TELL N ,SCORE>
                 <TELL " (total of 350 points), in ">
                 <TELL N ,MOVES>
                 <COND (<1? ,MOVES> <TELL " move.">) (ELSE <TELL " moves.">)>
                 <CRLF>
                 <TELL "This gives you the rank of ">
                 <COND (<EQUAL? ,SCORE 350> <TELL "Master Adventurer">)
                       (<G? ,SCORE 330> <TELL "Wizard">)
                       (<G? ,SCORE 300> <TELL "Master">)
                       (<G? ,SCORE 200> <TELL "Adventurer">)
                       (<G? ,SCORE 100> <TELL "Junior Adventurer">)
                       (<G? ,SCORE 50> <TELL "Novice Adventurer">)
                       (<G? ,SCORE 25> <TELL "Amateur Adventurer">)
                       (T <TELL "Beginner">)>
                 <TELL "." CR>
                 ,SCORE>

            <ROUTINE V-QUIT ("AUX" SCOR)
                 <V-SCORE>
                 <TELL
            "Do you wish to leave the game? (Y is affirmative): ">
                 <COND (<YES?>
                    <QUIT>)
                       (ELSE <TELL "Ok." CR>)>>

            <ROUTINE V-RESTART ()
                 <V-SCORE T>
                 <TELL "Do you wish to restart? (Y is affirmative): ">
                 <COND (<YES?>
                    <TELL "Restarting." CR>
                    <RESTART>
                    <TELL "Failed." CR>)>>

            <ROUTINE V-RESTORE ()
                 <COND (<RESTORE>
                    <TELL "Ok." CR>
                    <V-FIRST-LOOK>)
                       (T
                    <TELL "Failed." CR>)>>

            <ROUTINE FINISH ("AUX" WRD)
                 <V-SCORE>
                 <REPEAT ()
                     <CRLF>
                     <TELL
            "Would you like to restart the game from the beginning, restore a saved
            game position, or end this session of the game?|
            (Type RESTART, RESTORE, or QUIT):|
            >">
                     <READ ,P-INBUF ,P-LEXV>
                     <SET WRD <GET ,P-LEXV 1>>
                     <COND (<EQUAL? .WRD ,W?RESTART>
                        <RESTART>
                        <TELL "Failed." CR>)
                           (<EQUAL? .WRD ,W?RESTORE>
                        <COND (<RESTORE>
                               <TELL "Ok." CR>)
                              (T
                               <TELL "Failed." CR>)>)
                           (<EQUAL? .WRD ,W?QUIT ,W?Q>
                        <QUIT>)>>>
        """)
    }

    func testVFirstLook() throws {
        XCTAssertNoDifference(
            Game.routines.find("vFirstLook"),
            Statement(
                id: "vFirstLook",
                code: """
                    /// The `vFirstLook` (V-FIRST-LOOK) routine.
                    func vFirstLook() {
                        if describeRoom() {
                            if .isNot(superBrief) {
                                describeObjects()
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

    func testQuit() throws {
        XCTAssertNoDifference(
            Game.syntax.find("quit"),
            Statement(
                id: "quit",
                code: """
                    Syntax(
                        verb: "quit",
                        actionRoutine: "vQuit"
                    )
                    """,
                type: .void,
                category: .syntax,
                isCommittable: true
            )
        )
    }

    func testVQuit() throws {
        XCTAssertNoDifference(
            Game.routines.find("vQuit"),
            Statement(
                id: "vQuit",
                code: """
                    /// The `vQuit` (V-QUIT) routine.
                    func vQuit() {
                        // var scor: <Unknown>
                        vScore()
                        output("Do you wish to leave the game? (Y is affirmative): ")
                        if isYes() {
                            vQuit()
                        } else {
                            output("Ok.")
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

    func testRestart() throws {
        XCTAssertNoDifference(
            Game.syntax.find("restart"),
            Statement(
                id: "restart",
                code: """
                    Syntax(
                        verb: "restart",
                        actionRoutine: "vRestart"
                    )
                    """,
                type: .void,
                category: .syntax,
                isCommittable: true
            )
        )
    }

    func testVRestart() throws {
        XCTAssertNoDifference(
            Game.routines.find("vRestart"),
            Statement(
                id: "vRestart",
                code: """
                    /// The `vRestart` (V-RESTART) routine.
                    func vRestart() {
                        vScore(isAsk: true)
                        output("Do you wish to restart? (Y is affirmative): ")
                        if isYes() {
                            output("Restarting.")
                            vRestart()
                            output("Failed.")
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

    func testRestore() throws {
        XCTAssertNoDifference(
            Game.syntax.find("restore"),
            Statement(
                id: "restore",
                code: """
                    Syntax(
                        verb: "restore",
                        actionRoutine: "vRestore"
                    )
                    """,
                type: .void,
                category: .syntax,
                isCommittable: true
            )
        )
    }

    func testVRestore() throws {
        XCTAssertNoDifference(
            Game.routines.find("vRestore"),
            Statement(
                id: "vRestore",
                code: """
                    /// The `vRestore` (V-RESTORE) routine.
                    func vRestore() {
                        if restore() {
                            output("Ok.")
                            vFirstLook()
                        } else {
                            output("Failed.")
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

    func testVScore() throws {
        XCTAssertNoDifference(
            Game.routines.find("vScore"),
            Statement(
                id: "vScore",
                code: #"""
                    @discardableResult
                    /// The `vScore` (V-SCORE) routine.
                    func vScore(isAsk: Bool = true) -> Int {
                        output("Your score is ")
                        output(score)
                        output(" (total of 350 points), in ")
                        output(moves)
                        if moves.isOne {
                            output(" move.")
                        } else {
                            output(" moves.")
                        }
                        output("\n")
                        output("This gives you the rank of ")
                        if score.equals(350) {
                            output("Master Adventurer")
                        } else if score.isGreaterThan(330) {
                            output("Wizard")
                        } else if score.isGreaterThan(300) {
                            output("Master")
                        } else if score.isGreaterThan(200) {
                            output("Adventurer")
                        } else if score.isGreaterThan(100) {
                            output("Junior Adventurer")
                        } else if score.isGreaterThan(50) {
                            output("Novice Adventurer")
                        } else if score.isGreaterThan(25) {
                            output("Amateur Adventurer")
                        } else {
                            output("Beginner")
                        }
                        output(".")
                        return score
                    }
                    """#,
                type: .int,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testFinish() throws {
        XCTAssertNoDifference(
            Game.routines.find("finish"),
            Statement(
                id: "finish",
                code: #"""
                    /// The `finish` (FINISH) routine.
                    func finish() {
                        var wrd: Word? = nil
                        vScore()
                        while true {
                            output("\n")
                            output("""
                                Would you like to restart the game from the beginning, \
                                restore a saved game position, or end this session of the \
                                game?
                                (Type RESTART, RESTORE, or QUIT):
                                >
                                """)
                            read(&pInbuf, &pLexv)
                            wrd.set(to: try pLexv.get(at: 1))
                            if wrd.equals(Word.restart) {
                                vRestart()
                                output("Failed.")
                            } else if wrd.equals(Word.restore) {
                                if restore() {
                                    output("Ok.")
                                } else {
                                    output("Failed.")
                                }
                            } else if wrd.equals(Word.quit, Word.q) {
                                vQuit()
                            }
                        }
                    }
                    """#,
                type: .void,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
