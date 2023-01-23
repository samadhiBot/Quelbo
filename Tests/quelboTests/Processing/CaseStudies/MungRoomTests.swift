//
//  MungRoomTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class MungRoomTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
    }

    func testMungRoomZork1() {
        process("""
            <SETG ZORK-NUMBER 1>

            <ROUTINE MUNG-ROOM (RM STR)
                 %<COND (<==? ,ZORK-NUMBER 2>
                     '<COND (<EQUAL? .RM ,INSIDE-BARROW>
                         <RFALSE>)>)
                    (ELSE T)>
                 <FSET .RM ,RMUNGBIT>
                 <PUTP .RM ,P?LDESC .STR>>
        """)

        XCTAssertNoDifference(
            Game.routines.find("mungRoom"),
            Statement(
                id: "mungRoom",
                code: """
                    /// The `mungRoom` (MUNG-ROOM) routine.
                    func mungRoom(
                        rm: Object,
                        str: String
                    ) {
                        rm.isDestroyed.set(true)
                        rm.longDescription = str
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testMungRoomZork2() {
        process("""
            <SETG ZORK-NUMBER 2>

            <ROOM INSIDE-BARROW>

            <ROUTINE MUNG-ROOM (RM STR)
                 %<COND (<==? ,ZORK-NUMBER 2>
                     '<COND (<EQUAL? .RM ,INSIDE-BARROW>
                         <RFALSE>)>)
                    (ELSE T)>
                 <FSET .RM ,RMUNGBIT>
                 <PUTP .RM ,P?LDESC .STR>>
        """)

        XCTAssertNoDifference(
            Game.routines.find("mungRoom"),
            Statement(
                id: "mungRoom",
                code: """
                    @discardableResult
                    /// The `mungRoom` (MUNG-ROOM) routine.
                    func mungRoom(
                        rm: Object,
                        str: String
                    ) -> Bool {
                        if rm.equals(insideBarrow) {
                            return false
                        }
                        rm.isDestroyed.set(true)
                        rm.longDescription = str
                    }
                    """,
                type: .booleanFalse,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
