//
//  VillainBlowTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/2/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class VillainBlowTests: QuelboTests {
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
            <CONSTANT C-TICK 1>
            <CONSTANT CURE-WAIT 30>
            <CONSTANT F-DEF 1>         ;"means print defender name (villain, e.g.)"
            <CONSTANT F-WEP 0>         ;"means print weapon name"
            <CONSTANT HESITATE 8>      ;"hesitates (miss on free swing)"
            <CONSTANT KILLED 3>        ;"defender dead"
            <CONSTANT LIGHT-WOUND 4>   ;"defender lightly wounded"
            <CONSTANT LOSE-WEAPON 7>   ;"defender loses weapon"
            <CONSTANT MISSED 1>        ;"attacker misses"
            <CONSTANT SERIOUS-WOUND 5> ;"defender seriously wounded"
            <CONSTANT SITTING-DUCK 9>  ;"sitting duck (crunch!)"
            <CONSTANT STAGGER 6>       ;"defender staggered (miss turn)"
            <CONSTANT STRENGTH-MAX 7>
            <CONSTANT STRENGTH-MIN 2>
            <CONSTANT UNCONSCIOUS 2>   ;"defender unconscious"
            <CONSTANT V-BEST 1>        ;"best weapon"
            <CONSTANT V-BEST-ADV 2>    ;"advantage it confers"
            <CONSTANT V-MSGS 4>        ;"messages for that villain"
            <CONSTANT V-MSGS 4>        ;"messages for that villain"
            <CONSTANT V-VILLAIN 0>     ;"villain"

            <GLOBAL DEF1
                <TABLE (PURE)
                 MISSED MISSED MISSED MISSED
                 STAGGER STAGGER
                 UNCONSCIOUS UNCONSCIOUS
                 KILLED KILLED KILLED KILLED KILLED>>
            <GLOBAL DEF2A
                <TABLE (PURE)
                 MISSED MISSED MISSED MISSED MISSED
                 STAGGER STAGGER
                 LIGHT-WOUND LIGHT-WOUND
                 UNCONSCIOUS>>
            <GLOBAL DEF2B
                <TABLE (PURE)
                 MISSED MISSED MISSED
                 STAGGER STAGGER
                 LIGHT-WOUND LIGHT-WOUND LIGHT-WOUND
                 UNCONSCIOUS
                 KILLED KILLED KILLED>>
            <GLOBAL DEF3A
                <TABLE (PURE)
                 MISSED MISSED MISSED MISSED MISSED
                 STAGGER STAGGER
                 LIGHT-WOUND LIGHT-WOUND
                 SERIOUS-WOUND SERIOUS-WOUND>>
            <GLOBAL DEF3B
                <TABLE (PURE)
                 MISSED MISSED MISSED
                 STAGGER STAGGER
                 LIGHT-WOUND LIGHT-WOUND LIGHT-WOUND
                 SERIOUS-WOUND SERIOUS-WOUND SERIOUS-WOUND>>
            <GLOBAL DEF3C
                <TABLE (PURE)
                 MISSED
                 STAGGER STAGGER
                 LIGHT-WOUND LIGHT-WOUND LIGHT-WOUND LIGHT-WOUND
                 SERIOUS-WOUND SERIOUS-WOUND SERIOUS-WOUND>>
            <GLOBAL DEF1-RES
                <TABLE DEF1
                       0 ;<REST ,DEF1 2>
                       0 ;<REST ,DEF1 4>>>
            <GLOBAL DEF2-RES
                <TABLE DEF2A
                       DEF2B
                       0; <REST ,DEF2B 2>
                       0; <REST ,DEF2B 4>>>
            <GLOBAL DEF3-RES
                <TABLE DEF3A
                       0 ;<REST ,DEF3A 2>
                       DEF3B
                       0 ;<REST ,DEF3B 2>
                       DEF3C>>
            <GLOBAL HERE 0>
            <GLOBAL LOAD-ALLOWED 100>
            <GLOBAL SCORE-MAX 350>
            <GLOBAL THIEF-ENGROSSED <>>
            <GLOBAL WINNER 0>

            <OBJECT AXE>
            <OBJECT KNIFE>
            <OBJECT RUSTY-KNIFE>
            <OBJECT STILETTO>
            <OBJECT SWORD>

            <OBJECT THIEF
                (IN ROUND-ROOM)
                (SYNONYM THIEF ROBBER MAN PERSON)
                (ADJECTIVE SHADY SUSPICIOUS SEEDY)
                (DESC "thief")
                (FLAGS ACTORBIT INVISIBLE CONTBIT OPENBIT TRYTAKEBIT)
                (ACTION ROBBER-FUNCTION)
                (LDESC
            "There is a suspicious-looking individual, holding a large bag, leaning
            against one wall. He is armed with a deadly stiletto.")
                (STRENGTH 5)>

            <DEFMAC ENABLE ('INT) <FORM PUT .INT ,C-ENABLED? 1>>

            <ROUTINE ZPROB
                 (BASE)
                 <COND (,LUCKY <G? .BASE <RANDOM 100>>)
                       (ELSE <G? .BASE <RANDOM 300>>)>>

            <ROUTINE RANDOM-ELEMENT (FROB)
                 <GET .FROB <RANDOM <GET .FROB 0>>>>

            <DEFMAC PROB ('BASE? "OPTIONAL" 'LOSER?)
                <COND (<ASSIGNED? LOSER?> <FORM ZPROB .BASE?>)
                      (ELSE <FORM G? .BASE? '<RANDOM 100>>)>>

            <ROUTINE FIGHT-STRENGTH ("OPTIONAL" (ADJUST? T) "AUX" S)
                 <SET S
                      <+ ,STRENGTH-MIN
                     </ ,SCORE
                        </ ,SCORE-MAX
                           <- ,STRENGTH-MAX ,STRENGTH-MIN>>>>>
                 <COND (.ADJUST? <+ .S <GETP ,WINNER ,P?STRENGTH>>)(T .S)>>

            <ROUTINE FIND-WEAPON (O "AUX" W)
                 <SET W <FIRST? .O>>
                 <COND (<NOT .W>
                    <RFALSE>)>
                 <REPEAT ()
                     <COND (<OR <EQUAL? .W ,STILETTO ,AXE ,SWORD>
                            <EQUAL? .W ,KNIFE ,RUSTY-KNIFE>>
                        <RETURN .W>)
                           (<NOT <SET W <NEXT? .W>>> <RFALSE>)>>>

            <ROUTINE REMARK (REMARK D W "AUX" (LEN <GET .REMARK 0>) (CNT 0) STR)
                 <REPEAT ()
                         <COND (<G? <SET CNT <+ .CNT 1>> .LEN> <RETURN>)>
                     <SET STR <GET .REMARK .CNT>>
                     <COND (<EQUAL? .STR ,F-WEP> <PRINTD .W>)
                           (<EQUAL? .STR ,F-DEF> <PRINTD .D>)
                           (T <PRINT .STR>)>>
                 <CRLF>>

            <ROUTINE VILLAIN-STRENGTH (OO
                           "AUX" (VILLAIN <GET .OO ,V-VILLAIN>)
                           OD TMP)
                 <SET OD <GETP .VILLAIN ,P?STRENGTH>>
                 <COND (<NOT <L? .OD 0>>
                    <COND (<AND <EQUAL? .VILLAIN ,THIEF> ,THIEF-ENGROSSED>
                           <COND (<G? .OD 2> <SET OD 2>)>
                           <SETG THIEF-ENGROSSED <>>)>
                    <COND (<AND ,PRSI
                            <FSET? ,PRSI ,WEAPONBIT>
                            <EQUAL? <GET .OO ,V-BEST> ,PRSI>>
                           <SET TMP <- .OD <GET .OO ,V-BEST-ADV>>>
                           <COND (<L? .TMP 1> <SET TMP 1>)>
                           <SET OD .TMP>)>)>
                 .OD>

            <ROUTINE QUEUE (RTN TICK "AUX" CINT)
                 #DECL ((RTN) ATOM (TICK) FIX (CINT) <PRIMTYPE VECTOR>)
                 <PUT <SET CINT <INT .RTN>> ,C-TICK .TICK>
                 .CINT>

            <ROUTINE WINNER-RESULT (DEF RES OD)
                 <PUTP ,WINNER
                       ,P?STRENGTH
                       <COND (<0? .DEF> -10000)(T <- .DEF .OD>)>>
                 <COND (<L? <- .DEF .OD> 0>
                    <ENABLE <QUEUE I-CURE ,CURE-WAIT>>)>
                 <COND (<NOT <G? <FIGHT-STRENGTH> 0>>
                    <PUTP ,WINNER ,P?STRENGTH <+ 1 <- <FIGHT-STRENGTH <>>>>>
                    <JIGS-UP
            "It appears that that last blow was too much for you. I'm afraid you
            are dead.">
                    <>)
                       (T .RES)>>

            <ROUTINE VILLAIN-BLOW (OO OUT?
                           "AUX" (VILLAIN <GET .OO ,V-VILLAIN>)
                           (REMARKS <GET .OO ,V-MSGS>)
                           DWEAPON ATT DEF OA OD TBL RES NWEAPON)
                 <FCLEAR ,WINNER ,STAGGERED>
                 <COND (<FSET? .VILLAIN ,STAGGERED>
                    <TELL "The " D .VILLAIN
                          " slowly regains his feet." CR>
                    <FCLEAR .VILLAIN ,STAGGERED>
                    <RTRUE>)>
                 <SET OA <SET ATT <VILLAIN-STRENGTH .OO>>>
                 <COND (<NOT <G? <SET DEF <FIGHT-STRENGTH>> 0>> <RTRUE>)>
                 <SET OD <FIGHT-STRENGTH <>>>
                 <SET DWEAPON <FIND-WEAPON ,WINNER>>
                 <COND (<L? .DEF 0> <SET RES ,KILLED>)
                       (T
                    <COND (<1? .DEF>
                           <COND (<G? .ATT 2> <SET ATT 3>)>
                           <SET TBL <GET ,DEF1-RES <- .ATT 1>>>)
                          (<EQUAL? .DEF 2>
                           <COND (<G? .ATT 3> <SET ATT 4>)>
                           <SET TBL <GET ,DEF2-RES <- .ATT 1>>>)
                          (<G? .DEF 2>
                           <SET ATT <- .ATT .DEF>>
                           <COND (<L? .ATT -1> <SET ATT -2>)
                             (<G? .ATT 1> <SET ATT 2>)>
                           <SET TBL <GET ,DEF3-RES <+ .ATT 2>>>)>
                    <SET RES <GET .TBL <- <RANDOM 9> 1>>>
                    <COND (.OUT?
                           <COND (<EQUAL? .RES ,STAGGER> <SET RES ,HESITATE>)
                             (T <SET RES ,SITTING-DUCK>)>)>
                    <COND (<AND <EQUAL? .RES ,STAGGER>
                            .DWEAPON
                            <PROB 25 <COND (.HERO? 10)(T 50)>>>
                           <SET RES ,LOSE-WEAPON>)>
                    <REMARK
                      <RANDOM-ELEMENT <GET .REMARKS <- .RES 1>>>
                      ,WINNER
                      .DWEAPON>)>
                 <COND (<OR <EQUAL? .RES ,MISSED> <EQUAL? .RES ,HESITATE>>)
                       (<EQUAL? .RES ,UNCONSCIOUS>)
                       (<OR <EQUAL? .RES ,KILLED>
                        <EQUAL? .RES ,SITTING-DUCK>>
                    <SET DEF 0>)
                       (<EQUAL? .RES ,LIGHT-WOUND>
                    <SET DEF <- .DEF 1>>
                    <COND (<L? .DEF 0> <SET DEF 0>)>
                    <COND (<G? ,LOAD-ALLOWED 50>
                           <SETG LOAD-ALLOWED <- ,LOAD-ALLOWED 10>>)>)
                       (<EQUAL? .RES ,SERIOUS-WOUND>
                    <SET DEF <- .DEF 2>>
                    <COND (<L? .DEF 0> <SET DEF 0>)>
                    <COND (<G? ,LOAD-ALLOWED 50>
                           <SETG LOAD-ALLOWED <- ,LOAD-ALLOWED 20>>)>)
                       (<EQUAL? .RES ,STAGGER> <FSET ,WINNER ,STAGGERED>)
                       (T
                    ;<AND <EQUAL? .RES ,LOSE-WEAPON> .DWEAPON>
                    <MOVE .DWEAPON ,HERE>
                    <COND (<SET NWEAPON <FIND-WEAPON ,WINNER>>
                           <TELL
            "Fortunately, you still have a " D .NWEAPON "." CR>)>)>
                 <WINNER-RESULT .DEF .RES .OD>>
        """)
    }

    func testThief() throws {
        XCTAssertNoDifference(
            Game.objects.find("thief"),
            Statement(
                id: "thief",
                code: #"""
                    /// The `thief` (THIEF) object.
                    var thief = Object(
                        id: "thief",
                        action: "robberFunc",
                        adjectives: ["shady", "suspicious", "seedy"],
                        description: "thief",
                        flags: [
                            .isActor,
                            .isContainer,
                            .isInvisible,
                            .isOpen,
                            .noImplicitTake,
                        ],
                        location: "roundRoom",
                        longDescription: """
                            There is a suspicious-looking individual, holding a large \
                            bag, leaning against one wall. He is armed with a deadly \
                            stiletto.
                            """,
                        strength: 5,
                        synonyms: ["thief", "robber", "man", "person"]
                    )
                    """#,
                type: .object.tableElement,
                category: .objects,
                isCommittable: true
            )
        )
    }

    func testZprob() throws {
        XCTAssertNoDifference(
            Game.routines.find("zprob"),
            Statement(
                id: "zprob",
                code: """
                    /// The `zprob` (ZPROB) routine.
                    func zprob(base: Int) {
                        if Globals.lucky {
                            base.isGreaterThan(.random(100))
                        } else {
                            base.isGreaterThan(.random(300))
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

    func testRandomElement() throws {
        XCTAssertNoDifference(
            Game.routines.find("randomElement"),
            Statement(
                id: "randomElement",
                code: """
                    @discardableResult
                    /// The `randomElement` (RANDOM-ELEMENT) routine.
                    func randomElement(frob: Table) throws -> Table {
                        return try frob.get(at: .random(try frob.get(at: 0)))
                    }
                    """,
                type: .table.tableElement,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }

    func testProb() throws {
        XCTAssertNoDifference(
            Game.routines.find("prob"),
            Statement(
                id: "prob",
                code: """
                    /// The `prob` (PROB) macro.
                    func prob(isBase: Int, isLoser: Int? = nil) {
                        if isLoser.isAssigned {
                            zprob(base: isBase)
                        } else {
                            isBase.isGreaterThan(.random(100))
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

    func testFightStrength() throws {
        XCTAssertNoDifference(
            Game.routines.find("fightStrength"),
            Statement(
                id: "fightStrength",
                code: """
                    @discardableResult
                    /// The `fightStrength` (FIGHT-STRENGTH) routine.
                    func fightStrength(isAdjust: Bool = true) -> Int {
                        var s = 0
                        s.set(to: .add(
                            Constants.strengthMin,
                            .divide(
                                Globals.score,
                                .divide(
                                    Globals.scoreMax,
                                    .subtract(
                                        Constants.strengthMax,
                                        Constants.strengthMin
                                    )
                                )
                            )
                        ))
                        if isAdjust {
                            .add(s, Globals.winner.strength)
                        } else {
                            return s
                        }
                    }
                    """,
                type: .int.property.tableElement,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testFindWeapon() throws {
        XCTAssertNoDifference(
            Game.routines.find("findWeapon"),
            Statement(
                id: "findWeapon",
                code: """
                    @discardableResult
                    /// The `findWeapon` (FIND-WEAPON) routine.
                    func findWeapon(o: Object) -> Object? {
                        var w: Object?
                        w.set(to: o.firstChild)
                        if .isNot(w) {
                            return nil
                        }
                        while true {
                            if .or(
                                w.equals(
                                    Objects.stiletto,
                                    Objects.axe,
                                    Objects.sword
                                ),
                                w.equals(Objects.knife, Objects.rustyKnife)
                            ) {
                                return w
                            } else if .isNot(w.set(to: w.nextSibling)) {
                                return nil
                            }
                        }
                    }
                    """,
                type: .object.optional,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )

    }

    func testRemark() throws {
        XCTAssertNoDifference(
            Game.routines.find("remark"),
            Statement(
                id: "remark",
                code: #"""
                    /// The `remark` (REMARK) routine.
                    func remark(remark: Table, d: Object, w: Object) {
                        var len = try remark.get(at: 0)
                        var cnt = 0
                        var str = ""
                        while true {
                            if cnt.set(to: .add(cnt, 1)).isGreaterThan(len) {
                                break
                            }
                            str.set(to: try remark.get(at: cnt))
                            if str.equals(Constants.fWep) {
                                output(w.description)
                            } else if str.equals(Constants.fDef) {
                                output(d.description)
                            } else {
                                output(str)
                            }
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

    func testVillainStrength() throws {
        XCTAssertNoDifference(
            Game.routines.find("villainStrength"),
            Statement(
                id: "villainStrength",
                code: """
                    @discardableResult
                    /// The `villainStrength` (VILLAIN-STRENGTH) routine.
                    func villainStrength(oo: Table) -> Int {
                        var villain = try oo.get(at: Constants.vVillain)
                        var od = 0
                        var tmp = 0
                        od.set(to: villain.strength)
                        if .isNot(od.isLessThan(0)) {
                            if .and(
                                villain.equals(Objects.thief),
                                Globals.thiefEngrossed
                            ) {
                                if od.isGreaterThan(2) {
                                    od.set(to: 2)
                                }
                                Globals.thiefEngrossed.set(to: false)
                            }
                            if _ = .and(
                                .object("Globals.parsedIndirectObject"),
                                Globals.parsedIndirectObject.hasFlag(.isWeapon),
                                try oo.get(at: Constants.vBest).equals(Globals.parsedIndirectObject)
                            ) {
                                tmp.set(to: .subtract(od, try oo.get(at: Constants.vBestAdv)))
                                if tmp.isLessThan(1) {
                                    tmp.set(to: 1)
                                }
                                od.set(to: tmp)
                            }
                        }
                        return od
                    }
                    """,
                type: .int.property.tableElement,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testWinnerResult() throws {
        XCTAssertNoDifference(
            Game.routines.find("winnerResult"),
            Statement(
                id: "winnerResult",
                code: #"""
                    @discardableResult
                    /// The `winnerResult` (WINNER-RESULT) routine.
                    func winnerResult(def: Int, res: Int, od: Int) throws -> Int? {
                        var def = def
                        winner.strength = if def.isZero {
                            return -10000
                        } else {
                            .subtract(def, od)
                        }
                        if .subtract(def, od).isLessThan(0) {
                            try enable(
                                int: try queue(rtn: iCure, tick: Constants.cureWait)
                            )
                        }
                        if .isNot(fightStrength().isGreaterThan(0)) {
                            winner.strength = .add(1, -fightStrength(isAdjust: false))
                            try jigsUp(
                                desc: """
                                    It appears that that last blow was too much for you. I'm \
                                    afraid you are dead.
                                    """
                            )
                            return 0
                        } else {
                            return res
                        }
                    }
                    """#,
                type: .int.optional.tableElement,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }

    func testVillainBlow() throws {
        XCTAssertNoDifference(
            Game.routines.find("villainBlow"),
            Statement(
                id: "villainBlow",
                code: """
                    @discardableResult
                    /// The `villainBlow` (VILLAIN-BLOW) routine.
                    func villainBlow(oo: Table, isOut: Bool) throws -> Bool {
                        var villain = try oo.get(at: Constants.vVillain)
                        var remarks = try oo.get(at: Constants.vMsgs)
                        var dweapon: Object?
                        var att = 0
                        var def = 0
                        var oa = 0
                        var od = 0
                        var tbl: Table?
                        var res = 0
                        var nweapon: Object?
                        Globals.winner.isStaggered.set(false)
                        if villain.hasFlag(.isStaggered) {
                            output("The ")
                            output(villain.description)
                            output(" slowly regains his feet.")
                            villain.isStaggered.set(false)
                            return true
                        }
                        oa.set(to: att.set(to: villainStrength(oo: oo)))
                        if .isNot(def.set(to: fightStrength()).isGreaterThan(0)) {
                            return true
                        }
                        od.set(to: fightStrength(isAdjust: false))
                        dweapon.set(to: findWeapon(o: Globals.winner))
                        if def.isLessThan(0) {
                            res.set(to: Constants.killed)
                        } else {
                            if def.isOne {
                                if att.isGreaterThan(2) {
                                    att.set(to: 3)
                                }
                                tbl.set(to: try Globals.def1Res.get(at: .subtract(att, 1)))
                            } else if def.equals(2) {
                                if att.isGreaterThan(3) {
                                    att.set(to: 4)
                                }
                                tbl.set(to: try Globals.def2Res.get(at: .subtract(att, 1)))
                            } else if def.isGreaterThan(2) {
                                att.set(to: .subtract(att, def))
                                if att.isLessThan(-1) {
                                    att.set(to: -2)
                                } else if att.isGreaterThan(1) {
                                    att.set(to: 2)
                                }
                                tbl.set(to: try Globals.def3Res.get(at: .add(att, 2)))
                            }
                            res.set(to: try tbl.get(at: .subtract(.random(9), 1)))
                            if isOut {
                                if res.equals(Constants.stagger) {
                                    res.set(to: Constants.hesitate)
                                } else {
                                    res.set(to: Constants.sittingDuck)
                                }
                            }
                            if _ = .and(
                                res.equals(Constants.stagger),
                                .object("dweapon"),
                                prob(
                                    isBase: 25,
                                    isLoser: {
                                        if false /* Conditional failed to parse: HERO? */ else {
                                            return 50
                                        }
                                    }()
                                )
                            ) {
                                res.set(to: Constants.loseWeapon)
                            }
                            remark(
                                remark: try randomElement(
                                    frob: try remarks.get(at: .subtract(res, 1))
                                ),
                                d: Globals.winner,
                                w: dweapon
                            )
                        }
                        if .or(
                            res.equals(Constants.missed),
                            res.equals(Constants.hesitate)
                        ) {
                            // do nothing
                        } else if res.equals(Constants.unconscious) {
                            // do nothing
                        } else if .or(
                            res.equals(Constants.killed),
                            res.equals(Constants.sittingDuck)
                        ) {
                            def.set(to: 0)
                        } else if res.equals(Constants.lightWound) {
                            def.set(to: .subtract(def, 1))
                            if def.isLessThan(0) {
                                def.set(to: 0)
                            }
                            if Globals.loadAllowed.isGreaterThan(50) {
                                Globals.loadAllowed.set(to: .subtract(Globals.loadAllowed, 10))
                            }
                        } else if res.equals(Constants.seriousWound) {
                            def.set(to: .subtract(def, 2))
                            if def.isLessThan(0) {
                                def.set(to: 0)
                            }
                            if Globals.loadAllowed.isGreaterThan(50) {
                                Globals.loadAllowed.set(to: .subtract(Globals.loadAllowed, 20))
                            }
                        } else if res.equals(Constants.stagger) {
                            Globals.winner.isStaggered.set(true)
                        } else {
                            // <AND <EQUAL? .RES ,LOSE-WEAPON> .DWEAPON>
                            dweapon.move(to: Globals.here)
                            if _ = nweapon.set(to: findWeapon(o: Globals.winner)) {
                                output("Fortunately, you still have a ")
                                output(nweapon.description)
                                output(".")
                            }
                        }
                        try winnerResult(def: def, res: res, od: od)
                    }
                    """,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }
}
