////THIS-IT?
////
////  IsThisItTests.swift
////  Quelbo
////
////  Created by Chris Sessions on 10/9/22.
////
//
//import CustomDump
//import XCTest
//@testable import quelbo
//
//final class IsThisItTests: QuelboTests {
//    override func setUp() {
//        super.setUp()
//
//        process("""
//            <OBJECT TRAP-DOOR (FLAGS INVISIBLE)>
//
//            <GLOBAL P-NAM <>>
//
//            <ROUTINE THIS-IT? (OBJ TBL "AUX" SYNS)
//                <COND (<FSET? .OBJ ,INVISIBLE> <RFALSE>)
//                        (<AND ,P-NAM
//                        <NOT <ZMEMQ ,P-NAM
//                            <SET SYNS <GETPT .OBJ ,P?SYNONYM>>
//                            <- </ <PTSIZE .SYNS> 2> 1>>>>
//                    <RFALSE>)
//                        (<AND ,P-ADJ
//                        <OR <NOT <SET SYNS <GETPT .OBJ ,P?ADJECTIVE>>>
//                        <NOT <ZMEMQB ,P-ADJ .SYNS <- <PTSIZE .SYNS> 1>>>>>
//                    <RFALSE>)
//                        (<AND <NOT <ZERO? ,P-GWIMBIT>> <NOT <FSET? .OBJ ,P-GWIMBIT>>>
//                    <RFALSE>)>
//                <RTRUE>>
//
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
