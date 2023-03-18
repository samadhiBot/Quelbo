//
//  IntTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/26/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IntTests: QuelboTests {
    override func setUp() {
        super.setUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <CONSTANT C-INTLEN 6>
            <CONSTANT C-RTN 2>
            <CONSTANT C-TABLELEN 180>

            <GLOBAL C-DEMONS 180>
            <GLOBAL C-INTS 180>
            <GLOBAL C-TABLE <ITABLE NONE 180>>

            <ROUTINE INT (RTN "OPTIONAL" (DEMON <>) E C INT)
                 #DECL ((RTN) ATOM (DEMON) <OR ATOM FALSE> (E C INT) <PRIMTYPE
                                              VECTOR>)
                 <SET E <REST ,C-TABLE ,C-TABLELEN>>
                 <SET C <REST ,C-TABLE ,C-INTS>>
                 <REPEAT ()
                     <COND (<==? .C .E>
                        <SETG C-INTS <- ,C-INTS ,C-INTLEN>>
                        <AND .DEMON <SETG C-DEMONS <- ,C-DEMONS ,C-INTLEN>>>
                        <SET INT <REST ,C-TABLE ,C-INTS>>
                        <PUT .INT ,C-RTN .RTN>
                        <RETURN .INT>)
                           (<EQUAL? <GET .C ,C-RTN> .RTN> <RETURN .C>)>
                     <SET C <REST .C ,C-INTLEN>>>>
        """)
    }

    func testInt() throws {
        XCTAssertNoDifference(
            Game.routines.find("int"),
            Statement(
                id: "int",
                code: """
                    @discardableResult
                    /// The `int` (INT) routine.
                    func int(
                        rtn: TableElement,
                        demon: Bool = false,
                        e: Table? = nil,
                        c: Table? = nil,
                        int: Table? = nil
                    ) -> Table {
                        var e: Table? = e
                        var c: Table? = c
                        var int: Table? = int
                        e.set(to: Global.cTable.rest(bytes: Constant.cTablelen))
                        c.set(to: Global.cTable.rest(bytes: Global.cInts))
                        while true {
                            if c.equals(e) {
                                Global.cInts.set(to: .subtract(Global.cInts, Constant.cIntlen))
                                .and(
                                    demon,
                                    Global.cDemons.set(to: .subtract(Global.cDemons, Constant.cIntlen))
                                )
                                int.set(to: Global.cTable.rest(bytes: Global.cInts))
                                int.put(
                                    element: rtn,
                                    at: Constant.cRtn
                                )
                                return int
                            } else if try c.get(at: Constant.cRtn).equals(rtn) {
                                return c
                            }
                            c.set(to: c.rest(bytes: Constant.cIntlen))
                        }
                    }
                    """,
                type: .table.root,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
