//
//  SwordTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/24/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SwordTests: QuelboTests {
    override func setUp() {
        super.setUp()
        IntTests().sharedSetUp()

        process("""
            <CONSTANT CEXIT 4>
            <CONSTANT DEXIT 5>
            <CONSTANT UEXIT 1>

            <GLOBAL HERE 0>

            <SETG C-ENABLED? 0>

            <OBJECT ADVENTURER (FLAGS NDESCBIT INVISIBLE SACREDBIT ACTORBIT)>

            <OBJECT SWORD
                (IN LIVING-ROOM)
                (SYNONYM SWORD ORCRIST GLAMDRING BLADE)
                (ADJECTIVE ELVISH OLD ANTIQUE)
                (DESC "sword")
                (FLAGS TAKEBIT WEAPONBIT TRYTAKEBIT)
                (ACTION SWORD-FCN)
                (FDESC
            "Above the trophy case hangs an elvish sword of great antiquity.")
                (SIZE 30)
                (TVALUE 0)>

            <ROUTINE INFESTED? (R "AUX" (F <FIRST? .R>))
                 <REPEAT ()
                     <COND (<NOT .F> <RFALSE>)
                           (<AND <FSET? .F ,ACTORBIT> <NOT <FSET? .F ,INVISIBLE>>>
                        <RTRUE>)
                           (<NOT <SET F <NEXT? .F>>> <RFALSE>)>>>

            <ROUTINE I-SWORD ("AUX" (DEM <INT I-SWORD>) (G <GETP ,SWORD ,P?TVALUE>)
                            (NG 0) P T L)
                 <COND (<IN? ,SWORD ,ADVENTURER>
                    <COND (<INFESTED? ,HERE> <SET NG 2>)
                          (T
                           <SET P 0>
                           <REPEAT ()
                               <COND (<0? <SET P <NEXTP ,HERE .P>>>
                                  <RETURN>)
                                 (<NOT <L? .P ,LOW-DIRECTION>>
                                  <SET T <GETPT ,HERE .P>>
                                  <SET L <PTSIZE .T>>
                                  <COND (<EQUAL? .L ,UEXIT ,CEXIT ,DEXIT>
                                     <COND (<INFESTED? <GETB .T 0>>
                                        <SET NG 1>
                                        <RETURN>)>)>)>>)>
                    <COND (<EQUAL? .NG .G> <RFALSE>)
                          (<EQUAL? .NG 2>
                           <TELL "Your sword has begun to glow very brightly." CR>)
                          (<1? .NG>
                           <TELL "Your sword is glowing with a faint blue glow."
                             CR>)
                          (<0? .NG>
                           <TELL "Your sword is no longer glowing." CR>)>
                    <PUTP ,SWORD ,P?TVALUE .NG>
                    <RTRUE>)
                       (T
                    <PUT .DEM ,C-ENABLED? 0>
                    <RFALSE>)>>
        """)
    }

    func testSword() throws {
        XCTAssertNoDifference(
            Game.objects.find("sword"),
            Statement(
                id: "sword",
                code: #"""
                    /// The `sword` (SWORD) object.
                    var sword = Object(
                        id: "sword",
                        action: "swordFunc",
                        adjectives: ["elvish", "old", "antique"],
                        description: "sword",
                        firstDescription: """
                            Above the trophy case hangs an elvish sword of great \
                            antiquity.
                            """,
                        flags: [.isTakable, .isWeapon, .noImplicitTake],
                        location: "livingRoom",
                        size: 30,
                        synonyms: ["sword", "orcrist", "glamdring", "blade"],
                        takeValue: 0
                    )
                    """#,
                type: .object,
                category: .objects,
                isCommittable: true
            )
        )
    }

    func testISword() throws {
        XCTAssertNoDifference(
            Game.routines.find("iSword"),
            Statement(
                id: "iSword",
                code: """
                    @discardableResult
                    /// The `iSword` (I-SWORD) routine.
                    func iSword() throws -> Bool {
                        var dem = try int(rtn: iSword)
                        var g = Objects.sword.takeValue
                        var ng = 0
                        var p = 0
                        var t: Table?
                        var l = 0
                        if Objects.sword.isIn(Objects.adventurer) {
                            if isInfested(r: Globals.here) {
                                ng.set(to: 2)
                            } else {
                                p.set(to: 0)
                                while true {
                                    if p.set(to: here.property(after: p)).isZero {
                                        break
                                    } else if .isNot(p.isLessThan(Constants.lowDirection)) {
                                        t.set(to: Globals.here?.property(p))
                                        l.set(to: t.propertySize)
                                        if l.equals(
                                            Constants.uexit,
                                            Constants.cexit,
                                            Constants.dexit
                                        ) {
                                            if isInfested(r: try t.get(at: 0)) {
                                                ng.set(to: 1)
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                            if ng.equals(g) {
                                return false
                            } else if ng.equals(2) {
                                output("Your sword has begun to glow very brightly.")
                            } else if ng.isOne {
                                output("Your sword is glowing with a faint blue glow.")
                            } else if ng.isZero {
                                output("Your sword is no longer glowing.")
                            }
                            Objects.sword.takeValue = ng
                            return true
                        } else {
                            try dem.put(
                                element: 0,
                                at: Globals.isCEnabled
                            )
                            return false
                        }
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
