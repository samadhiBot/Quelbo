//
//  DoSlTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DoSlTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        SearchListTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <GLOBAL P-SLOCBITS 0>
            <GLOBAL P-TABLE 0>

            <ROUTINE DO-SL (OBJ BIT1 BIT2 "AUX" BTS)
                <COND (<BTST ,P-SLOCBITS <+ .BIT1 .BIT2>>
                       <SEARCH-LIST .OBJ ,P-TABLE ,P-SRCALL>)
                      (T
                       <COND (<BTST ,P-SLOCBITS .BIT1>
                          <SEARCH-LIST .OBJ ,P-TABLE ,P-SRCTOP>)
                         (<BTST ,P-SLOCBITS .BIT2>
                          <SEARCH-LIST .OBJ ,P-TABLE ,P-SRCBOT>)
                         (T <RTRUE>)>)>>

        """)
    }

    func testDoSl() throws {
        XCTAssertNoDifference(
            Game.routines.find("doSl"),
            Statement(
                id: "doSl",
                code: """
                    @discardableResult
                    /// The `doSl` (DO-SL) routine.
                    func doSl(obj: Object, bit1: Int, bit2: Int) -> Bool {
                        // var bts: <Unknown>
                        if _ = .bitwiseCompare(Global.pSlocbits, .add(bit1, bit2)) {
                            searchList(
                                obj: obj,
                                tbl: Global.pTable,
                                lvl: Constant.pSrcall
                            )
                        } else {
                            if _ = .bitwiseCompare(Global.pSlocbits, bit1) {
                                searchList(
                                    obj: obj,
                                    tbl: Global.pTable,
                                    lvl: Constant.pSrctop
                                )
                            } else if _ = .bitwiseCompare(Global.pSlocbits, bit2) {
                                searchList(
                                    obj: obj,
                                    tbl: Global.pTable,
                                    lvl: Constant.pSrcbot
                                )
                            } else {
                                return true
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
