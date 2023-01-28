//
//  DoFightTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/20/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class DoFightTests: QuelboTests {
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
        VillainBlowTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <CONSTANT V-VILLAIN 0>    ;"villain"
            <CONSTANT F-BUSY? 1>      ;"busy recovering weapon?"

            <GLOBAL VILLAINS
                <LTABLE <TABLE TROLL SWORD 1 0 TROLL-MELEE>
                    <TABLE THIEF KNIFE 1 0 THIEF-MELEE>
                    <TABLE CYCLOPS <> 0 0 CYCLOPS-MELEE>>>

            <ROUTINE DO-FIGHT (LEN "AUX" CNT RES O OO (OUT <>))
                <REPEAT ()
                      <SET CNT 0>
                      <REPEAT ()
                          <SET CNT <+ .CNT 1>>
                          <COND (<EQUAL? .CNT .LEN>
                             <SET RES T>
                             <RETURN T>)>
                          <SET OO <GET ,VILLAINS .CNT>>
                          <SET O <GET .OO ,V-VILLAIN>>
                          <COND (<NOT <FSET? .O ,FIGHTBIT>>)
                            (<APPLY <GETP .O ,P?ACTION>
                                ,F-BUSY?>)
                            (<NOT <SET RES
                                   <VILLAIN-BLOW
                                .OO
                                .OUT>>>
                             <SET RES <>>
                             <RETURN>)
                            (<EQUAL? .RES ,UNCONSCIOUS>
                             <SET OUT <+ 1 <RANDOM 3>>>)>>
                      <COND (.RES
                         <COND (<NOT .OUT> <RETURN>)
                           (T
                            <SET OUT <- .OUT 1>>
                            <COND (<0? .OUT> <RETURN>)>)>)
                        (T <RETURN>)>>>
        """)
    }

    func testDoFight() throws {
        XCTAssertNoDifference(
            Game.routines.find("doFight"),
            Statement(
                id: "doFight",
                code: """
                    @discardableResult
                    /// The `doFight` (DO-FIGHT) routine.
                    func doFight(len: Int) -> Bool {
                        var cnt: Int = 0
                        var res: Int? = 0
                        var o: Object? = nil
                        var oo: Table? = nil
                        var out: Bool = false
                        while true {
                            cnt.set(to: 0)
                            while true {
                                cnt.set(to: .add(cnt, 1))
                                if cnt.equals(len) {
                                    res.set(to: 1)
                                    return true
                                }
                                oo.set(to: try villains.get(at: cnt))
                                o.set(to: try oo.get(at: vVillain))
                                if .isNot(o.hasFlag(.isFightable)) {
                                    // do nothing
                                } else if _ = o.action(isFBusy) {
                                    // do nothing
                                } else if .isNot(res.set(to: villainBlow(oo: oo, isOut: out))) {
                                    res.set(to: 0)
                                    break
                                } else if res.equals(unconscious) {
                                    out.set(to: .add(1, .random(3)))
                                }
                            }
                            if _ = res {
                                if .isNot(out) {
                                    break
                                } else {
                                    out.set(to: .subtract(out, 1))
                                    if out.isFalse {
                                        break
                                    }
                                }
                            } else {
                                break
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
}
