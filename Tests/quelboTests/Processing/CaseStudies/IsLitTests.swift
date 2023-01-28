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
                    func isLit(
                        rm: Object,
                        rmBit: Bool = true
                    ) -> Bool {
                        var ohere: Object? = nil
                        var lit: Bool = false
                        if .and(
                            alwaysLit,
                            winner.equals(player)
                        ) {
                            return true
                        }
                        pGwimBit.set(to: onBit)
                        ohere.set(to: here)
                        here.set(to: rm)
                        if .and(
                            rmBit,
                            rm.hasFlag(.isOn)
                        ) {
                            lit.set(to: true)
                        } else {
                            try pMerge.put(element: 0, at: pMatchlen)
                            pTable.set(to: pMerge)
                            pSlocbits.set(to: -1)
                            if ohere.equals(rm) {
                                doSl(
                                    obj: winner,
                                    bit1: 1,
                                    bit2: 1
                                )
                                if .and(
                                    .isNot(winner.equals(player)),
                                    player.isIn(rm)
                                ) {
                                    doSl(
                                        obj: player,
                                        bit1: 1,
                                        bit2: 1
                                    )
                                }
                            }
                            doSl(
                                obj: rm,
                                bit1: 1,
                                bit2: 1
                            )
                            if try pTable.get(at: pMatchlen).isGreaterThan(0) {
                                lit.set(to: true)
                            }
                        }
                        here.set(to: ohere)
                        pGwimBit.set(to: false)
                        return lit
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
