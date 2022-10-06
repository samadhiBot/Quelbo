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

        process("""
            <SETG ZORK-NUMBER 1>

            <OBJECT GLOBAL-OBJECTS
                (FLAGS RMUNGBIT INVISIBLE TOUCHBIT SURFACEBIT TRYTAKEBIT
                       OPENBIT SEARCHBIT TRANSBIT ONBIT RLANDBIT FIGHTBIT
                       STAGGERED WEARBIT)>

            <ROUTINE MUNG-ROOM (RM STR)
                 %<COND (<==? ,ZORK-NUMBER 2>
                     '<COND (<EQUAL? .RM ,INSIDE-BARROW>
                         <RFALSE>)>)
                    (ELSE T)>
                 <FSET .RM ,RMUNGBIT>
                 <PUTP .RM ,P?LDESC .STR>>
        """, type: .mdl)
    }

    func testMungRoom() {
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
                        if zorkNumber.equals(2) {
                            if rm.equals(insideBarrow) {
                                return false
                            }
                        } else {
                            return true
                        }
                        rm.isDestroyed.set(true)
                        rm.longDescription = str
                    }
                    """,
                type: .booleanFalse,
                category: .routines,
                isCommittable: true
            )
        )
    }
}
