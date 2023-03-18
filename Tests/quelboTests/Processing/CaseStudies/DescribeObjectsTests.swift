//
//  DescribeObjectsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/11/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class DescribeObjectsTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        DescribeObjectTests().sharedSetUp()
        DescribeRoomTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <ROUTINE DESCRIBE-OBJECTS ("OPTIONAL" (V? <>))
                 <COND (,LIT
                    <COND (<FIRST? ,HERE>
                           <PRINT-CONT ,HERE <SET V? <OR .V? ,VERBOSE>> -1>)>)
                       (T
                    <TELL "Only bats can see in the dark. And you're not one." CR>)>>
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
                        var isV = false
                        if Global.lit {
                            if _ = Global.here.firstChild {
                                printCont(
                                    obj: Global.here,
                                    isV: isV.set(to: .or(isV, Global.verbose)),
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
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
