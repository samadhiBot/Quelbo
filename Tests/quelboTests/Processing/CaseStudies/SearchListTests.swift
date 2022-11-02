////
////  SearchListTests.swift
////  Quelbo
////
////  Created by Chris Sessions on 10/9/22.
////
//
//import CustomDump
//import XCTest
//@testable import quelbo
//
//final class SearchListTests: QuelboTests {
//    override func setUp() {
//        super.setUp()
//
//        process("""
//            <CONSTANT P-SRCBOT 2>
//            <CONSTANT P-SRCTOP 0>
//            <CONSTANT P-SRCALL 1>
//
//            <ROUTINE SEARCH-LIST (OBJ TBL LVL "AUX" FLS NOBJ)
//                <COND (<SET OBJ <FIRST? .OBJ>>
//                       <REPEAT ()
//                           <COND (<AND <NOT <EQUAL? .LVL ,P-SRCBOT>>
//                               <GETPT .OBJ ,P?SYNONYM>
//                               <THIS-IT? .OBJ .TBL>>
//                              <OBJ-FOUND .OBJ .TBL>)>
//                           <COND (<AND <OR <NOT <EQUAL? .LVL ,P-SRCTOP>>
//                                   <FSET? .OBJ ,SEARCHBIT>
//                                   <FSET? .OBJ ,SURFACEBIT>>
//                               <SET NOBJ <FIRST? .OBJ>>
//                               <OR <FSET? .OBJ ,OPENBIT>
//                                   <FSET? .OBJ ,TRANSBIT>>>
//                              <SET FLS
//                               <SEARCH-LIST .OBJ
//                                    .TBL
//                                    <COND (<FSET? .OBJ ,SURFACEBIT>
//                                           ,P-SRCALL)
//                                          (<FSET? .OBJ ,SEARCHBIT>
//                                           ,P-SRCALL)
//                                          (T ,P-SRCTOP)>>>)>
//                           <COND (<SET OBJ <NEXT? .OBJ>>) (T <RETURN>)>>)>>
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
