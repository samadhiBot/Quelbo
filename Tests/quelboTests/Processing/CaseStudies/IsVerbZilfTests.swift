////
////  IsVerbZilfTests.swift
////  Quelbo
////
////  Created by Chris Sessions on 10/5/22.
////
//
//import CustomDump
//import XCTest
//@testable import quelbo
//
//final class IsVerbZilfTests: QuelboTests {
//    override func setUp() {
//        super.setUp()
//
//        process("""
//            <GLOBAL PRSA <>>
//
//            <DEFMAC VERB? ("ARGS" A "AUX" O)
//                <SET O <MAPF ,LIST
//                    <FUNCTION (I)
//                        <FORM GVAL <PARSE <STRING "V?" <SPNAME .I>>>>>
//                    .A>>
//                <FORM EQUAL? ',PRSA !.O>>
//
//            <ROUTINE TREASURE-INSIDE ()
//                     <COND (<VERB? OPEN>
//                        <TELL "You've found an emerald!" CR>
//                        <RFALSE>)>>
//        """, type: .mdl)
//    }
//
//    func testZilfIsVerb() throws {
//        XCTAssertNoDifference(
//            Game.routines.find("isVerb"),
//            Statement(
//                id: "isVerb",
//                code: """
//                    @discardableResult
//                    /// The `isVerb` (VERB?) macro.
//                    func isVerb(a: <Unknown>) -> Bool {
//                        var o: Verb? = nil
//                        o.set(to: <Mapf result>)
//                        return prsa.equals(o)
//                    }
//                    """,
//                type: .bool,
//                category: .routines,
//                isCommittable: true
//            )
//        )
//    }
//
//    func testMethodThatCallsIsVerb() {
//        let treasureInside = process("""
//            <ROUTINE TREASURE-INSIDE ()
//                     <COND (<VERB? OPEN>
//                        <TELL "You've found an emerald!" CR>
//                        <RFALSE>)>>
//        """)
//
//        XCTAssertNoDifference(treasureInside, .statement(
//            id: "treasureInside",
//            code: """
//                @discardableResult
//                /// The `treasureInside` (TREASURE-INSIDE) routine.
//                func treasureInside() -> Bool {
//                    if isVerb(atms: open) {
//                        output("You've found an emerald!")
//                        return false
//                    }
//                }
//                """,
//            type: .booleanFalse,
//            category: .routines,
//            isCommittable: true
//        ))
//    }
//}
