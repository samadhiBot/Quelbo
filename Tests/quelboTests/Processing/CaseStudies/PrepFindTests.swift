////PREP-FIND
////
////  PrepFindTests.swift
////  Quelbo
////
////  Created by Chris Sessions on 10/9/22.
////
//
//import CustomDump
//import XCTest
//@testable import quelbo
//
//final class PrepFindTests: QuelboTests {
//    override func setUp() {
//        super.setUp()
//
//        process("""
//            <BUZZ>
//        """)
//    }
//
//    func testBuzz() throws {
//        XCTAssertNoDifference(
//            Game.routines.find("buzz"),
//            Statement(
//                id: "buzz",
//                code: """
//                    """,
//                type: .void,
//                category: .routines,
//                isCommittable: true
//            )
//        )
//    }
//}
