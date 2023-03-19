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

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <GLOBAL WINNER 0>

            <OBJECT LOCAL-GLOBALS (IN GLOBAL-OBJECTS)>
            <OBJECT ROOMS (IN TO ROOMS)>

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
                        // "can player TOUCH object?"
                        // "revised 5/2/84 by SEM and SWG"
                        if obj.hasFlag(.isInvisible) {
                            return false
                        } else if .isNot(l) {
                            return false
                        } else if l.equals(Objects.globalObjects) {
                            return true
                        } else if .and(
                            l.equals(Objects.localGlobals),
                            isGlobalIn(obj1: obj, obj2: Globals.here)
                        ) {
                            return true
                        } else if .isNot(metaLoc(obj: obj).equals(Globals.here, Globals.winner.parent)) {
                            return false
                        } else if l.equals(
                            Globals.winner,
                            Globals.here,
                            Globals.winner.parent
                        ) {
                            return true
                        } else if .and(l.hasFlag(.isOpen), isAccessible(obj: l)) {
                            return true
                        } else {
                            return false
                        }
                    }
                    """,
                type: .bool,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
