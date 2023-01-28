////
////  MultifrobTests.swift
////  Quelbo
////
////  Created by Chris Sessions on 10/2/22.
////
//
//import CustomDump
//import XCTest
//@testable import quelbo
//
//final class MultifrobTests: QuelboTests {
//    override func setUp() {
//        super.setUp()
//
//        process("""
//            <GLOBAL PRSA <>>
//
//            <DEFINE MULTIFROB (X ATMS "AUX" (OO (OR)) (O .OO) (L ()) ATM)
//                <REPEAT ()
//                    <COND (<EMPTY? .ATMS>
//                           <RETURN!- <COND (<LENGTH? .OO 1> <ERROR .X>)
//                                   (<LENGTH? .OO 2> <NTH .OO 2>)
//                                   (ELSE <CHTYPE .OO FORM>)>>)>
//                    <REPEAT ()
//                        <COND (<EMPTY? .ATMS> <RETURN!->)>
//                        <SET ATM <NTH .ATMS 1>>
//                        <SET L
//                             (<COND (<TYPE? .ATM ATOM>
//                                 <FORM GVAL
//                                   <COND (<==? .X PRSA>
//                                      <PARSE
//                                        <STRING "V?"
//                                            <SPNAME .ATM>>>)
//                                     (ELSE .ATM)>>)
//                                (ELSE .ATM)>
//                              !.L)>
//                        <SET ATMS <REST .ATMS>>
//                        <COND (<==? <LENGTH .L> 3> <RETURN!->)>>
//                    <SET O <REST <PUTREST .O (<FORM EQUAL? <FORM GVAL .X> !.L>)>>>
//                    <SET L ()>>>
//
//            <DEFMAC VERB? ("ARGS" ATMS)
//                <MULTIFROB PRSA .ATMS>>
//
//            <DEFMAC PRSO? ("ARGS" ATMS)
//                <MULTIFROB PRSO .ATMS>>
//
//            <DEFMAC PRSI? ("ARGS" ATMS)
//                <MULTIFROB PRSI .ATMS>>
//
//            <DEFMAC ROOM? ("ARGS" ATMS)
//                <MULTIFROB HERE .ATMS>>
//
//            <ROUTINE BOARD-F ()
//                 <COND (<VERB? TAKE EXAMINE>
//                    <TELL "The boards are securely fastened." CR>)>>
//        """, type: .mdl)
//    }
//
//    func testZorkMultifrob() throws {
//        XCTAssertNoDifference(
//            Game.routines.find("multifrob"),
//            Statement(
//                id: "multifrob",
//                code: """
//
//                    """,
//                type: .void,
//                category: .routines,
//                isCommittable: true,
//                returnHandling: .passthrough
//            )
//        )
//    }
//
//    func testZorkIsVerb() throws {
//        XCTAssertNoDifference(
//            Game.routines.find("isVerb"),
//            Statement(
//                id: "isVerb",
//                code: """
//                    /// The `isVerb` (VERB?) macro.
//                    func isParsedVerb(atms: [⛔️]) {
//                        var atms: [⛔️] = atms
//                        multifrob(
//                            parserAction: parserAction,
//                            atms: atms
//                        )
//                    }
//                    """,
//                type: .bool,
//                category: .routines,
//                isCommittable: true,
//                returnHandling: .passthrough
//            )
//        )
//    }
//
//    func testMethodThatCallsFizmoIsVerb() {
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
//                    if isParsedVerb(atms: open) {
//                        output("You've found an emerald!")
//                        return false
//                    }
//                }
//                """,
//            type: .booleanFalse,
//            category: .routines,
//            isCommittable: true,
//            returnHandling: .passthrough
//        ))
//    }
//}
