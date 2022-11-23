//
//  IsAccessibleTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsAccessibleTests: QuelboTests {
    override func setUp() {
        super.setUp()

        process("""
            <GLOBAL WINNER 0>

            <OBJECT GLOBAL-OBJECTS
                (FLAGS RMUNGBIT INVISIBLE TOUCHBIT SURFACEBIT TRYTAKEBIT OPENBIT SEARCHBIT
                 TRANSBIT ONBIT RLANDBIT FIGHTBIT STAGGERED WEARBIT)>
            <OBJECT LOCAL-GLOBALS (IN GLOBAL-OBJECTS)>
            <OBJECT ROOMS (IN TO ROOMS)>

            <ROUTINE ZMEMQB (ITM TBL SIZE "AUX" (CNT 0))
                <REPEAT ()
                    <COND (<EQUAL? .ITM <GETB .TBL .CNT>>
                           <RTRUE>)
                          (<IGRTR? CNT .SIZE>
                           <RFALSE>)>>>

            <ROUTINE GLOBAL-IN? (OBJ1 OBJ2 "AUX" TX)
                 <COND (<SET TX <GETPT .OBJ2 ,P?GLOBAL>>
                    <ZMEMQB .OBJ1 .TX <- <PTSIZE .TX> 1>>)>>

            <ROUTINE META-LOC (OBJ)
                 <REPEAT ()
                     <COND (<NOT .OBJ>
                        <RFALSE>)
                           (<IN? .OBJ ,GLOBAL-OBJECTS>
                        <RETURN ,GLOBAL-OBJECTS>)>
                     <COND (<IN? .OBJ ,ROOMS>
                        <RETURN .OBJ>)
                           (T
                        <SET OBJ <LOC .OBJ>>)>>>

            <ROUTINE ACCESSIBLE? (OBJ "AUX" (L <LOC .OBJ>)) ;"can player TOUCH object?"
                 ;"revised 5/2/84 by SEM and SWG"
                 <COND (<FSET? .OBJ ,INVISIBLE>
                    <RFALSE>)
                       ;(<EQUAL? .OBJ ,PSEUDO-OBJECT>
                    <COND (<EQUAL? ,LAST-PSEUDO-LOC ,HERE>
                           <RTRUE>)
                          (T
                           <RFALSE>)>)
                       (<NOT .L>
                    <RFALSE>)
                       (<EQUAL? .L ,GLOBAL-OBJECTS>
                    <RTRUE>)
                       (<AND <EQUAL? .L ,LOCAL-GLOBALS>
                         <GLOBAL-IN? .OBJ ,HERE>>
                    <RTRUE>)
                       (<NOT <EQUAL? <META-LOC .OBJ> ,HERE <LOC ,WINNER>>>
                    <RFALSE>)
                       (<EQUAL? .L ,WINNER ,HERE <LOC ,WINNER>>
                    <RTRUE>)
                       (<AND <FSET? .L ,OPENBIT>
                          <ACCESSIBLE? .L>>
                    <RTRUE>)
                       (T
                    <RFALSE>)>>
        """)
    }

    func testZmemqb() throws {
        XCTAssertNoDifference(
            Game.routines.find("zmemqb"),
            Statement(
                id: "zmemqb",
                code: """
                    @discardableResult
                    /// The `zmemqb` (ZMEMQB) routine.
                    func zmemqb(
                        itm: TableElement,
                        tbl: Table,
                        size: Int
                    ) -> Bool {
                        var cnt: Int = 0
                        while true {
                            if itm.equals(try tbl.get(at: cnt)) {
                                return true
                            } else if cnt.increment().isGreaterThan(size) {
                                return false
                            }
                        }
                    }
                    """,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true
            )
        )
    }

    func testIsAccessible() throws {
        XCTAssertNoDifference(
            Game.routines.find("isAccessible"),
            Statement(
                id: "isAccessible",
                code: """
                    @discardableResult
                    /// The `isAccessible` (ACCESSIBLE?) routine.
                    func isAccessible(obj: Object) -> Bool {
                        var l: Object? = obj.parent
                        var obj: Object = obj
                        // "can player TOUCH object?"
                        // "revised 5/2/84 by SEM and SWG"
                        if obj.hasFlag(isInvisible) {
                            return false
                        } else if .isNot(l) {
                            return false
                        } else if l.equals(globalObjects) {
                            return true
                        } else if .and(
                            l.equals(localGlobals),
                            isGlobalIn(obj1: obj, obj2: here)
                        ) {
                            return true
                        } else if .isNot(metaLoc(obj: obj).equals(here, winner.parent)) {
                            return false
                        } else if l.equals(
                            winner,
                            here,
                            winner.parent,
                        ) {
                            return true
                        } else if .and(
                            l.hasFlag(isOpen),
                            isAccessible(obj: l)
                        ) {
                            return true
                        } else {
                            return false
                        }
                    }
                    """,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true
            )
        )
    }
}
