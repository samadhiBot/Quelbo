//
//  ZmemqTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ZmemqTests: QuelboTests {
    override func setUp() {
        super.setUp()
        sharedSetup()
    }

    func sharedSetup() {
        GlobalObjectsTests().sharedSetup()

        process("""
            <ROUTINE ZMEMQ (ITM TBL "OPTIONAL" (SIZE -1) "AUX" (CNT 1))
                <COND (<NOT .TBL> <RFALSE>)>
                <COND (<NOT <L? .SIZE 0>> <SET CNT 0>)
                      (ELSE <SET SIZE <GET .TBL 0>>)>
                <REPEAT ()
                    <COND (<EQUAL? .ITM <GET .TBL .CNT>>
                           <RETURN <REST .TBL <* .CNT 2>>>)
                          (<IGRTR? CNT .SIZE> <RFALSE>)>>>

            <ROUTINE ZMEMQB (ITM TBL SIZE "AUX" (CNT 0))
                <REPEAT ()
                    <COND (<EQUAL? .ITM <GETB .TBL .CNT>>
                           <RTRUE>)
                          (<IGRTR? CNT .SIZE>
                           <RFALSE>)>>>
        """)
    }

    func testZmemq() throws {
        XCTAssertNoDifference(
            Game.routines.find("zmemq"),
            Statement(
                id: "zmemq",
                code: """
                    @discardableResult
                    /// The `zmemq` (ZMEMQ) routine.
                    func zmemq(
                        itm: TableElement,
                        tbl: Table,
                        size: Int = -1
                    ) -> Table? {
                        var cnt: Int = 1
                        var size: Int = -1
                        if .isNot(tbl) {
                            return nil
                        }
                        if .isNot(size.isLessThan(0)) {
                            cnt.set(to: 0)
                        } else {
                            size.set(to: try tbl.get(at: 0))
                        }
                        while true {
                            if itm.equals(try tbl.get(at: cnt)) {
                                return tbl.rest(bytes: .multiply(cnt, 2))
                            } else if cnt.increment().isGreaterThan(size) {
                                return nil
                            }
                        }
                    }
                    """,
                type: .table.optional,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
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
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
