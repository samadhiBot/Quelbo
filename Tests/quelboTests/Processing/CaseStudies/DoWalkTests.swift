//
//  DoWalkTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DoWalkTests: QuelboTests {
    override func setUp() {
        super.setUp()

        DescribeRoomTests().setUp(for: .zork1)
        DescribeObjectTests().setUp(for: .zork1)

        process("""
            <ROUTINE DESCRIBE-OBJECTS ("OPTIONAL" (V? <>))
                 <COND (,LIT
                    <COND (<FIRST? ,HERE>
                           <PRINT-CONT ,HERE <SET V? <OR .V? ,VERBOSE>> -1>)>)
                       (T
                    <TELL "Only bats can see in the dark. And you're not one." CR>)>>

            <ROUTINE DO-WALK ()
                 <COND (<DESCRIBE-ROOM T>
                    <DESCRIBE-OBJECTS T>)>>
        """)
    }

    func testDescribeObjects() throws {
        XCTAssertNoDifference(
            Game.routines.find("describeObjects"),
            Statement(
                id: "describeObjects",
                code: """
                    /// The `describeObjects` (DESCRIBE-OBJECTS) routine.
                    func describeObjects(isV: Bool = false) {
                        var isV: Bool = false
                        if lit {
                            if _ = here.firstChild {
                                printCont(
                                    obj: here,
                                    isV: isV.set(to: .or(isV, verbose)),
                                    level: -1
                                )
                            }
                        } else {
                            output("Only bats can see in the dark. And you're not one.")
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true
            )
        )
    }

    func testDoWalk() throws {
        XCTAssertNoDifference(
            Game.routines.find("doWalk"),
            Statement(
                id: "doWalk",
                code: """
                    /// The `doWalk` (DO-WALK) routine.
                    func doWalk() {
                        if describeRoom(isLook: true) {
                            describeObjects(isV: true)
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true
            )
        )
    }
}
