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
        sharedSetUp()
    }

    func sharedSetUp() {
        process(#"""
            <SETG ZORK-NUMBER 1>

            <CONSTANT M-ENTER 2>

            <ROOM CANYON-VIEW>
            <ROOM CLEARING>
            <ROOM EAST-OF-HOUSE>
            <ROOM EGYPT-ROOM>
            <ROOM ENTRANCE-TO-HADES>
            <ROOM FOREST-1>
            <ROOM FOREST-1>
            <ROOM FOREST-2>
            <ROOM FOREST-3>
            <ROOM GRATING-CLEARING>
            <ROOM LIVING-ROOM>
            <ROOM NORTH-OF-HOUSE>
            <ROOM PATH>
            <ROOM SOUTH-OF-HOUSE>
            <ROOM SOUTH-TEMPLE>
            <ROOM WEST-OF-HOUSE>

            <GLOBAL ABOVE-GROUND
              <LTABLE (PURE) WEST-OF-HOUSE NORTH-OF-HOUSE EAST-OF-HOUSE SOUTH-OF-HOUSE
                  FOREST-1 FOREST-2 FOREST-3 PATH CLEARING GRATING-CLEARING
                  CANYON-VIEW>>
            <GLOBAL BASE-SCORE 0>
            <GLOBAL DEAD <>>
            <GLOBAL DEATHS 0>
            <GLOBAL LUCKY T>
            <GLOBAL SPRAYED? <>>
            <GLOBAL SUPER-BRIEF <>>
            <GLOBAL TROLL-FLAG <>>
            <GLOBAL WON-FLAG <>>

            <OBJECT ADVENTURER (FLAGS NDESCBIT INVISIBLE SACREDBIT ACTORBIT)>
            <OBJECT COFFIN>
            <OBJECT LAMP>
            <OBJECT MAP>
            <OBJECT MATCH>
            <OBJECT ROOMS (IN TO ROOMS)>
            <OBJECT SWORD>
            <OBJECT TRAP-DOOR>

            <DEFMAC DISABLE ('INT) <FORM PUT .INT ,C-ENABLED? 0>>

            <ROUTINE RANDOMIZE-OBJECTS ("AUX" (R <>) F N L)
                 <COND (<IN? ,LAMP ,WINNER>
                    <MOVE ,LAMP ,LIVING-ROOM>)>
                 <COND (<IN? ,COFFIN ,WINNER>
                    <MOVE ,COFFIN ,EGYPT-ROOM>)>
                 <PUTP ,SWORD ,P?TVALUE 0>
                 <SET N <FIRST? ,WINNER>>
                 <SET L <GET ,ABOVE-GROUND 0>>
                 <REPEAT ()
                     <SET F .N>
                     <COND (<NOT .F> <RETURN>)>
                     <SET N <NEXT? .F>>
                     <COND (<G? <GETP .F ,P?TVALUE> 0>
                        <REPEAT ()
                            <COND (<NOT .R> <SET R <FIRST? ,ROOMS>>)>
                            <COND (<AND <FSET? .R ,RLANDBIT>
                                    <NOT <FSET? .R ,ONBIT>>
                                    <PROB 50>>
                                   <MOVE .F .R>
                                   <RETURN>)
                                  (ELSE <SET R <NEXT? .R>>)>>)
                           (ELSE
                        <MOVE .F <GET ,ABOVE-GROUND <RANDOM .L>>>)>>>

            <ROUTINE KILL-INTERRUPTS ()
                 <DISABLE <INT I-XB>>
                 <DISABLE <INT I-XC>>
                 <DISABLE <INT I-CYCLOPS>>
                 <DISABLE <INT I-LANTERN>>
                 <DISABLE <INT I-CANDLES>>
                 <DISABLE <INT I-SWORD>>
                 <DISABLE <INT I-FOREST-ROOM>>
                 <DISABLE <INT I-MATCH>>
                 <FCLEAR ,MATCH ,ONBIT>
                 <RTRUE>>

            <ROUTINE NO-GO-TELL (AV WLOC)
                 <COND (.AV
                    <TELL "You can't go there in a " D .WLOC ".">)
                       (T
                    <TELL "You can't go there without a vehicle.">)>
                 <CRLF>>

            <ROUTINE SCORE-UPD (NUM)
                 <SETG BASE-SCORE <+ ,BASE-SCORE .NUM>>
                 <SETG SCORE <+ ,SCORE .NUM>>
                 %<COND (<==? ,ZORK-NUMBER 1>
                     '<COND (<AND <EQUAL? ,SCORE 350>
                                  <NOT ,WON-FLAG>>
                             <SETG WON-FLAG T>
                             <FCLEAR ,MAP ,INVISIBLE>
                             <FCLEAR ,WEST-OF-HOUSE ,TOUCHBIT>
                             <TELL
            "An almost inaudible voice whispers in your ear, \"Look to your treasures
            for the final secret.\"" CR>)>)
                    (T
                     '<NULL-F>)>
                 T>

            <ROUTINE SCORE-OBJ (OBJ "AUX" TEMP)
                 <COND (<G? <SET TEMP <GETP .OBJ ,P?VALUE>> 0>
                    <SCORE-UPD .TEMP>
                    <PUTP .OBJ ,P?VALUE 0>)>>

            <ROUTINE GOTO (RM "OPTIONAL" (V? T)
                       "AUX" (LB <FSET? .RM ,RLANDBIT>) (WLOC <LOC ,WINNER>)
                             (AV <>) OLIT OHERE)
                 <SET OLIT ,LIT>
                 <SET OHERE ,HERE>
                 <COND (<FSET? .WLOC ,VEHBIT>
                    <SET AV <GETP .WLOC ,P?VTYPE>>)>
                 <COND (<AND <NOT .LB>
                         <NOT .AV>>
                    <NO-GO-TELL .AV .WLOC>
                    <RFALSE>)
                       (<AND <NOT .LB>
                         <NOT <FSET? .RM .AV>>>
                    <NO-GO-TELL .AV .WLOC>
                    <RFALSE>)
                       (<AND <FSET? ,HERE ,RLANDBIT>
                         .LB
                         .AV
                         <NOT <EQUAL? .AV ,RLANDBIT>>
                         <NOT <FSET? .RM .AV>>>
                    <NO-GO-TELL .AV .WLOC>
                    <RFALSE>)
                       (<FSET? .RM ,RMUNGBIT>
                    <TELL <GETP .RM ,P?LDESC> CR>
                    <RFALSE>)
                       (T
                    <COND (<AND .LB
                            <NOT <FSET? ,HERE ,RLANDBIT>>
                            <NOT ,DEAD>
                            <FSET? .WLOC ,VEHBIT>>
                           %<COND (<==? ,ZORK-NUMBER 1>
                               '<TELL
            "The " D .WLOC " comes to a rest on the shore." CR CR>)
                              (<==? ,ZORK-NUMBER 2>
                               '<COND (<EQUAL? .WLOC ,BALLOON>
                                   <TELL
            "The balloon lands." CR>)
                                  (<FSET? .WLOC ,VEHBIT>
                                   <TELL
            "The " D .WLOC " comes to a stop." CR CR>)>)
                              (<==? ,ZORK-NUMBER 3>
                               '<COND (<FSET? .WLOC ,VEHBIT>
                                   <TELL
            "The " D .WLOC " comes to a stop." CR CR>)>)>)>
                    <COND (.AV
                           <MOVE .WLOC .RM>)
                          (T
                           <MOVE ,WINNER .RM>)>
                    <SETG HERE .RM>
                    <SETG LIT <LIT? ,HERE>>
                    <COND (<AND <NOT .OLIT>
                            <NOT ,LIT>
                            <PROB 80>>
                           <COND (,SPRAYED?
                              <TELL
            "There are sinister gurgling noises in the darkness all around you!" CR>)
                             %<COND (<==? ,ZORK-NUMBER 3>
                                 '(<EQUAL? ,HERE ,DARK-1 ,DARK-2>
                                           <JIGS-UP
            "Oh, no! Dozen of lurking grues attack and devour you! You must have
            stumbled into an authentic grue lair!">))
                                (T
                                 '(<NULL-F>
                                   <RFALSE>))>
                             (T
                              <TELL
            "Oh, no! A lurking grue slithered into the ">
                              <COND (<FSET? <LOC ,WINNER> ,VEHBIT>
                                 <TELL D <LOC ,WINNER>>)
                                (T <TELL "room">)>
                              <JIGS-UP " and devoured you!">
                              <RTRUE>)>)>
                    <COND (<AND <NOT ,LIT>
                            <EQUAL? ,WINNER ,ADVENTURER>>
                           <TELL "You have moved into a dark place." CR>
                           <SETG P-CONT <>>)>
                    <APPLY <GETP ,HERE ,P?ACTION> ,M-ENTER>
                    <SCORE-OBJ .RM>
                    <COND (<NOT <EQUAL? ,HERE .RM>> <RTRUE>)
                          (<AND <NOT <EQUAL? ,ADVENTURER ,WINNER>>
                            <IN? ,ADVENTURER .OHERE>>
                           <TELL "The " D ,WINNER " leaves the room." CR>)
                          %<COND (<==? ,ZORK-NUMBER 1>
                              '(<AND <EQUAL? ,HERE .OHERE>
                                  ;"no double description"
                                 <EQUAL? ,HERE ,ENTRANCE-TO-HADES>>
                            <RTRUE>))
                             (ELSE
                              '(<NULL-F> <RTRUE>))>
                          (<AND .V?
                            <EQUAL? ,WINNER ,ADVENTURER>>
                           <V-FIRST-LOOK>)>
                    <RTRUE>)>>

            <ROUTINE JIGS-UP (DESC "OPTIONAL" (PLAYER? <>))
                  <SETG WINNER ,ADVENTURER>
                 <COND (,DEAD
                    <TELL "|
            It takes a talented person to be killed while already dead. YOU are such
            a talent. Unfortunately, it takes a talented person to deal with it.
            I am not such a talent. Sorry." CR>
                    <FINISH>)>
                 <TELL .DESC CR>
                 <COND (<NOT ,LUCKY>
                    <TELL "Bad luck, huh?" CR>)>
                 <PROG ()
                       <SCORE-UPD -10>
                       <TELL "
            |    ****  You have died  ****
            |
            |">
                       <COND (<FSET? <LOC ,WINNER> ,VEHBIT>
                          <MOVE ,WINNER ,HERE>)>
                       <COND
                    (<NOT <L? ,DEATHS 2>>
                     <TELL
            "You clearly are a suicidal maniac.  We don't allow psychotics in the
            cave, since they may harm other adventurers.  Your remains will be
            installed in the Land of the Living Dead, where your fellow
            adventurers may gloat over them." CR>
                     <FINISH>)
                    (T
                     <SETG DEATHS <+ ,DEATHS 1>>
                     <MOVE ,WINNER ,HERE>
                     <COND (<FSET? ,SOUTH-TEMPLE ,TOUCHBIT>
                        <TELL
            "As you take your last breath, you feel relieved of your burdens. The
            feeling passes as you find yourself before the gates of Hell, where
            the spirits jeer at you and deny you entry.  Your senses are
            disturbed.  The objects in the dungeon appear indistinct, bleached of
            color, even unreal." CR CR>
                        <SETG DEAD T>
                        <SETG TROLL-FLAG T>
                        ;<SETG GWIM-DISABLE T>
                        <SETG ALWAYS-LIT T>
                        <PUTP ,WINNER ,P?ACTION DEAD-FUNCTION>
                        <GOTO ,ENTRANCE-TO-HADES>)
                           (T
                        <TELL
            "Now, let's take a look here...
            Well, you probably deserve another chance.  I can't quite fix you
            up completely, but you can't have everything." CR CR>
                        <GOTO ,FOREST-1>)>
                     <FCLEAR ,TRAP-DOOR ,TOUCHBIT>
                     <SETG P-CONT <>>
                     <RANDOMIZE-OBJECTS>
                     <KILL-INTERRUPTS>
                     <RFATAL>)>>>
        """#)
    }

    func testDisable() throws {
        XCTAssertNoDifference(
            Game.routines.find("disable"),
            Statement(
                id: "disable",
                code: """
                    /// The `disable` (DISABLE) macro.
                    func disable(int: Table) {
                        int.put(
                            element: 0,
                            at: isCEnabled
                        )
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testRandomizeObjects() throws {
        XCTAssertNoDifference(
            Game.routines.find("randomizeObjects"),
            Statement(
                id: "randomizeObjects",
                code: """
                    /// The `randomizeObjects` (RANDOMIZE-OBJECTS) routine.
                    func randomizeObjects() {
                        var r: Object?
                        var f: Object?
                        var n: Object?
                        var l = 0
                        if Objects.lamp.isIn(Globals.winner) {
                            lamp.move(to: Rooms.livingRoom)
                        }
                        if Objects.coffin.isIn(Globals.winner) {
                            coffin.move(to: Rooms.egyptRoom)
                        }
                        sword.takeValue = 0
                        n.set(to: Globals.winner.firstChild)
                        l.set(to: try Constants.aboveGround.get(at: 0))
                        while true {
                            f.set(to: n)
                            if .isNot(f) {
                                break
                            }
                            n.set(to: f.nextSibling)
                            if f.takeValue.isGreaterThan(0) {
                                while true {
                                    if .isNot(r) {
                                        r.set(to: Objects.rooms.firstChild)
                                    }
                                    if .and(
                                        r.hasFlag(.isDryLand),
                                        .isNot(r.hasFlag(.isOn)),
                                        prob(isBase: 50)
                                    ) {
                                        f.move(to: r)
                                        break
                                    } else {
                                        r.set(to: r.nextSibling)
                                    }
                                }
                            } else {
                                f.move(to: try Constants.aboveGround.get(at: .random(l)))
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

    func testKillInterrupts() throws {
        XCTAssertNoDifference(
            Game.routines.find("killInterrupts"),
            Statement(
                id: "killInterrupts",
                code: """
                    @discardableResult
                    /// The `killInterrupts` (KILL-INTERRUPTS) routine.
                    func killInterrupts() -> Bool {
                        disable(int: int(rtn: iXb))
                        disable(int: int(rtn: iXc))
                        disable(int: int(rtn: iCyclops))
                        disable(int: int(rtn: iLantern))
                        disable(int: int(rtn: iCandles))
                        disable(int: int(rtn: iSword))
                        disable(int: int(rtn: iForestRoom))
                        disable(int: int(rtn: iMatch))
                        Objects.match.isOn.set(false)
                        return true
                    }
                    """,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testNoGoTell() throws {
        XCTAssertNoDifference(
            Game.routines.find("noGoTell"),
            Statement(
                id: "noGoTell",
                code: #"""
                    /// The `noGoTell` (NO-GO-TELL) routine.
                    func noGoTell(av: Bool, wloc: Object) {
                        if av {
                            output("You can't go there in a ")
                            output(wloc.description)
                            output(".")
                        } else {
                            output("You can't go there without a vehicle.")
                        }
                        output("\n")
                    }
                    """#,
                type: .void,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testScoreUpd() throws {
        XCTAssertNoDifference(
            Game.routines.find("scoreUpd"),
            Statement(
                id: "scoreUpd",
                code: #"""
                    @discardableResult
                    /// The `scoreUpd` (SCORE-UPD) routine.
                    func scoreUpd(num: Int) -> Bool {
                        Globals.baseScore.set(to: .add(Globals.baseScore, num))
                        Globals.score.set(to: .add(Globals.score, num))
                        if .and(
                            Globals.score.equals(350),
                            .isNot(Globals.wonFlag)
                        ) {
                            Globals.wonFlag.set(to: true)
                            Objects.map.isInvisible.set(false)
                            Rooms.westOfHouse.hasBeenTouched.set(false)
                            output("""
                                An almost inaudible voice whispers in your ear, "Look to \
                                your treasures for the final secret."
                                """)
                        }
                        return true
                    }
                    """#,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testScoreObj() throws {
        XCTAssertNoDifference(
            Game.routines.find("scoreObj"),
            Statement(
                id: "scoreObj",
                code: """
                    /// The `scoreObj` (SCORE-OBJ) routine.
                    func scoreObj(obj: Object) {
                        var temp = 0
                        if temp.set(to: obj.value).isGreaterThan(0) {
                            scoreUpd(num: temp)
                            obj.value = 0
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

    func testGoto() throws {
        XCTAssertNoDifference(
            Game.routines.find("goto"),
            Statement(
                id: "goto",
                code: #"""
                    @discardableResult
                    /// The `goto` (GOTO) routine.
                    func goto(rm: Object, isV: Bool = true) -> Bool {
                        var lb = rm.hasFlag(.isDryLand)
                        var wloc = Globals.winner.parent
                        var av = false
                        var olit = false
                        var ohere: Object?
                        olit.set(to: Globals.lit)
                        ohere.set(to: Globals.here)
                        if wloc.hasFlag(.isVehicle) {
                            av.set(to: wloc.vehicleType)
                        }
                        if .and(.isNot(lb), .isNot(av)) {
                            noGoTell(av: av, wloc: wloc)
                            return false
                        } else if .and(.isNot(lb), .isNot(rm.hasFlag(.av))) {
                            noGoTell(av: av, wloc: wloc)
                            return false
                        } else if .and(
                            Globals.here.hasFlag(.isDryLand),
                            lb,
                            av,
                            .isNot(av.equals(.isDryLand)),
                            .isNot(rm.hasFlag(.av))
                        ) {
                            noGoTell(av: av, wloc: wloc)
                            return false
                        } else if rm.hasFlag(.isDestroyed) {
                            output(rm.longDescription)
                            return false
                        } else {
                            if .and(
                                lb,
                                .isNot(Globals.here.hasFlag(.isDryLand)),
                                .isNot(Globals.dead),
                                wloc.hasFlag(.isVehicle)
                            ) {
                                output("The ")
                                output(wloc.description)
                                output(" comes to a rest on the shore.")
                            }
                            if av {
                                wloc.move(to: rm)
                            } else {
                                winner.move(to: rm)
                            }
                            Globals.here.set(to: rm)
                            Globals.lit.set(to: isLit(rm: Globals.here))
                            if .and(
                                .isNot(olit),
                                .isNot(Globals.lit),
                                prob(isBase: 80)
                            ) {
                                if Globals.isSprayed {
                                    output("""
                                        There are sinister gurgling noises in the darkness all \
                                        around you!
                                        """)
                                } else if nullFunc() {
                                    return false
                                } else {
                                    output("Oh, no! A lurking grue slithered into the ")
                                    if Globals.winner.parent.hasFlag(.isVehicle) {
                                        output(Globals.winner.parent.description)
                                    } else {
                                        output("room")
                                    }
                                    jigsUp(desc: " and devoured you!")
                                    return true
                                }
                            }
                            if .and(
                                .isNot(Globals.lit),
                                Globals.winner.equals(Objects.adventurer)
                            ) {
                                output("You have moved into a dark place.")
                                pCont.set(to: false)
                            }
                            Globals.here.action(Constants.mEnter)
                            scoreObj(obj: rm)
                            if .isNot(Globals.here.equals(rm)) {
                                return true
                            } else if .and(
                                .isNot(Objects.adventurer.equals(Globals.winner)),
                                Objects.adventurer.isIn(ohere)
                            ) {
                                output("The ")
                                output(Globals.winner.description)
                                output(" leaves the room.")
                            } else if .and(
                                Globals.here.equals(ohere),
                                Globals.here.equals(Rooms.entranceToHades)
                            ) {
                                return true
                            } else if .and(
                                isV,
                                Globals.winner.equals(Objects.adventurer)
                            ) {
                                vFirstLook()
                            }
                            return true
                        }
                    }
                    """#,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testJigsUp() throws {
        XCTAssertNoDifference(
            Game.routines.find("jigsUp"),
            Statement(
                id: "jigsUp",
                code: #"""
                    /// The `jigsUp` (JIGS-UP) routine.
                    func jigsUp(desc: String, isPlayer: Bool = false) {
                        Globals.winner.set(to: Objects.adventurer)
                        if Globals.dead {
                            output("""

                                It takes a talented person to be killed while already dead. \
                                YOU are such a talent. Unfortunately, it takes a talented \
                                person to deal with it. I am not such a talent. Sorry.
                                """)
                            finish()
                        }
                        output(desc)
                        if .isNot(Globals.lucky) {
                            output("Bad luck, huh?")
                        }
                        do {
                            scoreUpd(num: -10)
                            output("""

                                    ****  You have died  ****


                                """)
                            if Globals.winner.parent.hasFlag(.isVehicle) {
                                winner.move(to: Globals.here)
                            }
                            if .isNot(Globals.deaths.isLessThan(2)) {
                                output("""
                                    You clearly are a suicidal maniac. We don't allow psychotics \
                                    in the cave, since they may harm other adventurers. Your \
                                    remains will be installed in the Land of the Living Dead, \
                                    where your fellow adventurers may gloat over them.
                                    """)
                                finish()
                            } else {
                                Globals.deaths.set(to: .add(Globals.deaths, 1))
                                winner.move(to: Globals.here)
                                if Rooms.southTemple.hasFlag(.hasBeenTouched) {
                                    output("""
                                        As you take your last breath, you feel relieved of your \
                                        burdens. The feeling passes as you find yourself before the \
                                        gates of Hell, where the spirits jeer at you and deny you \
                                        entry. Your senses are disturbed. The objects in the dungeon \
                                        appear indistinct, bleached of color, even unreal.
                                        """)
                                    Globals.dead.set(to: true)
                                    Globals.trollFlag.set(to: true)
                                    // <SETG GWIM-DISABLE T>
                                    Globals.alwaysLit.set(to: true)
                                    winner.action = deadFunc
                                    goto(rm: Rooms.entranceToHades)
                                } else {
                                    output("""
                                        Now, let's take a look here... Well, you probably deserve \
                                        another chance. I can't quite fix you up completely, but you \
                                        can't have everything.
                                        """)
                                    goto(rm: Rooms.forest1)
                                }
                                Objects.trapDoor.hasBeenTouched.set(false)
                                pCont.set(to: false)
                                randomizeObjects()
                                killInterrupts()
                                returnFatal()
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
