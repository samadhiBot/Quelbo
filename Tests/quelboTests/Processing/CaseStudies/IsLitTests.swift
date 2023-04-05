//
//  IsLitTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsLitTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        SearchListTests().sharedSetUp()
        DoSlTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <GLOBAL ALWAYS-LIT <>>
            <GLOBAL P-MATCHLEN 0>
            <GLOBAL P-MERGE <ITABLE NONE 50>>
            <GLOBAL PLAYER <>>
            <GLOBAL WINNER 0>

            <ROUTINE LIT? (RM "OPTIONAL" (RMBIT T) "AUX" OHERE (LIT <>))
                <COND (<AND ,ALWAYS-LIT <EQUAL? ,WINNER ,PLAYER>>
                       <RTRUE>)>
                <SETG P-GWIMBIT ,ONBIT>
                <SET OHERE ,HERE>
                <SETG HERE .RM>
                <COND (<AND .RMBIT
                        <FSET? .RM ,ONBIT>>
                       <SET LIT T>)
                      (T
                       <PUT ,P-MERGE ,P-MATCHLEN 0>
                       <SETG P-TABLE ,P-MERGE>
                       <SETG P-SLOCBITS -1>
                       <COND (<EQUAL? .OHERE .RM>
                          <DO-SL ,WINNER 1 1>
                          <COND (<AND <NOT <EQUAL? ,WINNER ,PLAYER>>
                              <IN? ,PLAYER .RM>>
                             <DO-SL ,PLAYER 1 1>)>)>
                       <DO-SL .RM 1 1>
                       <COND (<G? <GET ,P-TABLE ,P-MATCHLEN> 0> <SET LIT T>)>)>
                <SETG HERE .OHERE>
                <SETG P-GWIMBIT 0>
                .LIT>
        """)
    }

    func testIsLit() throws {
        XCTAssertNoDifference(
            Game.routines.find("isLit"),
            Statement(
                id: "isLit",
                code: """
                    @discardableResult
                    /// The `isLit` (LIT?) routine.
                    func isLit(rm: Object, rmBit: Bool = true) throws -> Bool {
                        var ohere: Object?
                        var lit = false
                        if .and(
                            Globals.alwaysLit,
                            Globals.winner.equals(Globals.player)
                        ) {
                            return true
                        }
                        Globals.pGwimBit.set(to: .isOn)
                        ohere.set(to: Globals.here)
                        Globals.here?.set(to: rm)
                        if .and(rmBit, rm.hasFlag(.isOn)) {
                            lit.set(to: true)
                        } else {
                            try Globals.pMerge.put(
                                element: 0,
                                at: Globals.pMatchlen
                            )
                            Globals.pTable.set(to: Globals.pMerge)
                            Globals.pSlocbits.set(to: -1)
                            if ohere.equals(rm) {
                                try doSl(obj: Globals.winner, bit1: 1, bit2: 1)
                                if .and(
                                    .isNot(Globals.winner.equals(Globals.player)),
                                    Globals.player.isIn(rm)
                                ) {
                                    try doSl(obj: Globals.player, bit1: 1, bit2: 1)
                                }
                            }
                            try doSl(obj: rm, bit1: 1, bit2: 1)
                            if try Globals.pTable.get(at: Globals.pMatchlen).isGreaterThan(0) {
                                lit.set(to: true)
                            }
                        }
                        Globals.here?.set(to: ohere)
                        Globals.pGwimBit.set(to: false)
                        return lit
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
