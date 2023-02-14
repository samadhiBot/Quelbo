//
//  NotHereTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/5/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class NotHereTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        IsAccessibleTests().sharedSetUp()
        BufferPrintTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process(#"""
            <CONSTANT P-NC1 6>
            <CONSTANT P-NC1L 7>
            <CONSTANT P-NC2 8>
            <CONSTANT P-NC2L 9>

            <GLOBAL P-ITBL <TABLE 0 0 0 0 0 0 0 0 0 0>>
            <GLOBAL P-PRSI <ITABLE NONE 50>>
            <GLOBAL P-PRSO <ITABLE NONE 50>>
            <GLOBAL P-XADJ <>>
            <GLOBAL P-XADJN <>>
            <GLOBAL P-XNAM <>>
            <GLOBAL PLAYER <>>

            <OBJECT NOT-HERE-OBJECT
                (DESC "such thing" ;"[not here]")
                (ACTION NOT-HERE-OBJECT-F)>

            <ROUTINE NOT-HERE-PRINT (PRSO?)
             <COND (,P-OFLAG
                <COND (,P-XADJ <PRINTB ,P-XADJN>)>
                <COND (,P-XNAM <PRINTB ,P-XNAM>)>)
                   (.PRSO?
                <BUFFER-PRINT <GET ,P-ITBL ,P-NC1> <GET ,P-ITBL ,P-NC1L> <>>)
                   (T
                <BUFFER-PRINT <GET ,P-ITBL ,P-NC2> <GET ,P-ITBL ,P-NC2L> <>>)>>

            <ROUTINE NOT-HERE-OBJECT-F ("AUX" TBL (PRSO? T) OBJ)
                 ;"This COND is game independent (except the TELL)"
                 <COND (<AND <EQUAL? ,PRSO ,NOT-HERE-OBJECT>
                         <EQUAL? ,PRSI ,NOT-HERE-OBJECT>>
                    <TELL "Those things aren't here!" CR>
                    <RTRUE>)
                       (<EQUAL? ,PRSO ,NOT-HERE-OBJECT>
                    <SET TBL ,P-PRSO>)
                       (T
                    <SET TBL ,P-PRSI>
                    <SET PRSO? <>>)>
                 ;"Here is the default 'cant see any' printer"
                 <SETG P-CONT <>>
                 <SETG QUOTE-FLAG <>>
                 <COND (<EQUAL? ,WINNER ,PLAYER>
                    <TELL "You can't see any ">
                    <NOT-HERE-PRINT .PRSO?>
                    <TELL " here!" CR>)
                       (T
                    <TELL "The " D ,WINNER " seems confused. \"I don't see any ">
                    <NOT-HERE-PRINT .PRSO?>
                    <TELL " here!\"" CR>)>
                 <RTRUE>>
        """#)
    }

    func testNotHereObject() throws {
        XCTAssertNoDifference(
            Game.objects.find("notHereObject"),
            Statement(
                id: "notHereObject",
                code: """
                    /// The `notHereObject` (NOT-HERE-OBJECT) object.
                    var notHereObject = Object(
                        id: "notHereObject",
                        action: notHereObjectFunc,
                        description: "such thing"
                    )
                    """,
                type: .object.optional,
                category: .objects,
                isCommittable: true
            )
        )
    }

    func testNotHerePrint() throws {
        XCTAssertNoDifference(
            Game.routines.find("notHerePrint"),
            Statement(
                id: "notHerePrint",
                code: """
                    /// The `notHerePrint` (NOT-HERE-PRINT) routine.
                    func notHerePrint(isPrso: Bool) {
                        if pOflag {
                            if pXadj {
                                output(pXadjn)
                            }
                            if let pXnam {
                                output(pXnam)
                            }
                        } else if isPrso {
                            bufferPrint(
                                beg: try pItbl.get(at: pNc1),
                                end: try pItbl.get(at: pNc1L),
                                cp: false
                            )
                        } else {
                            bufferPrint(
                                beg: try pItbl.get(at: pNc2),
                                end: try pItbl.get(at: pNc2L),
                                cp: false
                            )
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

    func testNotHereObjectFunc() throws {
        XCTAssertNoDifference(
            Game.routines.find("notHereObjectFunc"),
            Statement(
                id: "notHereObjectFunc",
                code: #"""
                    @discardableResult
                    /// The `notHereObjectFunc` (NOT-HERE-OBJECT-F) routine.
                    func notHereObjectFunc() -> Bool {
                        var tbl: Table? = nil
                        var isPrso: Bool = true
                        // var obj: <Unknown>
                        // "This COND is game independent (except the TELL)"
                        if .and(
                            parsedDirectObject.equals(notHereObject),
                            parsedIndirectObject.equals(notHereObject)
                        ) {
                            output("Those things aren't here!")
                            return true
                        } else if parsedDirectObject.equals(notHereObject) {
                            tbl.set(to: pPrso)
                        } else {
                            tbl.set(to: pPrsi)
                            isPrso.set(to: false)
                        }
                        // "Here is the default 'cant see any' printer"
                        pCont.set(to: false)
                        quoteFlag.set(to: false)
                        if winner.equals(player) {
                            output("You can't see any ")
                            notHerePrint(isPrso: isPrso)
                            output(" here!")
                        } else {
                            output("The ")
                            output(winner.description)
                            output(" seems confused. \"I don't see any ")
                            notHerePrint(isPrso: isPrso)
                            output(" here!\"")
                        }
                        return true
                    }
                    """#,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
