//
//  JigsUpTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class JigsUpTests: QuelboTests {
//    override func setUp() {
//        super.setUp()
//
//        process("""
//            <ROUTINE JIGS-UP (DESC "OPTIONAL" (PLAYER? <>))
//                  <SETG WINNER ,ADVENTURER>
//                 <COND (,DEAD
//                    <TELL "|
//            It takes a talented person to be killed while already dead. YOU are such
//            a talent. Unfortunately, it takes a talented person to deal with it.
//            I am not such a talent. Sorry." CR>
//                    <FINISH>)>
//                 <TELL .DESC CR>
//                 <COND (<NOT ,LUCKY>
//                    <TELL "Bad luck, huh?" CR>)>
//                 <PROG ()
//                       <SCORE-UPD -10>
//                       <TELL "
//            |    ****  You have died  ****
//            |
//            |">
//                       <COND (<FSET? <LOC ,WINNER> ,VEHBIT>
//                          <MOVE ,WINNER ,HERE>)>
//                       <COND
//                    (<NOT <L? ,DEATHS 2>>
//                     <TELL
//            "You clearly are a suicidal maniac.  We don't allow psychotics in the
//            cave, since they may harm other adventurers.  Your remains will be
//            installed in the Land of the Living Dead, where your fellow
//            adventurers may gloat over them." CR>
//                     <FINISH>)
//                    (T
//                     <SETG DEATHS <+ ,DEATHS 1>>
//                     <MOVE ,WINNER ,HERE>
//                     <COND (<FSET? ,SOUTH-TEMPLE ,TOUCHBIT>
//                        <TELL
//            "As you take your last breath, you feel relieved of your burdens. The
//            feeling passes as you find yourself before the gates of Hell, where
//            the spirits jeer at you and deny you entry.  Your senses are
//            disturbed.  The objects in the dungeon appear indistinct, bleached of
//            color, even unreal." CR CR>
//                        <SETG DEAD T>
//                        <SETG TROLL-FLAG T>
//                        ;<SETG GWIM-DISABLE T>
//                        <SETG ALWAYS-LIT T>
//                        <PUTP ,WINNER ,P?ACTION DEAD-FUNCTION>
//                        <GOTO ,ENTRANCE-TO-HADES>)
//                           (T
//                        <TELL
//            "Now, let's take a look here...
//            Well, you probably deserve another chance.  I can't quite fix you
//            up completely, but you can't have everything." CR CR>
//                        <GOTO ,FOREST-1>)>
//                     <FCLEAR ,TRAP-DOOR ,TOUCHBIT>
//                     <SETG P-CONT <>>
//                     <RANDOMIZE-OBJECTS>
//                     <KILL-INTERRUPTS>
//                     <RFATAL>)>>>
//        """)
//    }
//
//    func testJigsUp() throws {
//        XCTAssertNoDifference(
//            Game.routines.find("jigsUp"),
//            Statement(
//                id: "jigsUp",
//                code: """
//                    """,
//                type: .void,
//                category: .routines,
//                isCommittable: true
//            )
//        )
//    }
}
