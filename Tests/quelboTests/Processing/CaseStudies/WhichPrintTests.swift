//
//  WhichPrintTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 12/30/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class WhichPrintTests: QuelboTests {
    override func setUp() {
        super.setUp()

        BufferPrintTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <CONSTANT P-NC1 6>
            <CONSTANT P-NC1L 7>
            <CONSTANT P-NC2 8>
            <CONSTANT P-NC2L 9>

            <GLOBAL P-ADJ <>>
            <GLOBAL P-ADJN <>>
            <GLOBAL P-AND <>>
            <GLOBAL P-ITBL <TABLE 0 0 0 0 0 0 0 0 0 0>>
            <GLOBAL P-NAM <>>
            <GLOBAL P-PRSO <ITABLE NONE 50>>

            <ROUTINE THING-PRINT (PRSO? "OPTIONAL" (THE? <>) "AUX" BEG END)
                 <COND (.PRSO?
                    <SET BEG <GET ,P-ITBL ,P-NC1>>
                    <SET END <GET ,P-ITBL ,P-NC1L>>)
                       (ELSE
                    <SET BEG <GET ,P-ITBL ,P-NC2>>
                    <SET END <GET ,P-ITBL ,P-NC2L>>)>
                 <BUFFER-PRINT .BEG .END .THE?>>

            <ROUTINE WHICH-PRINT (TLEN LEN TBL "AUX" OBJ RLEN)
                 <SET RLEN .LEN>
                 <TELL "Which ">
                     <COND (<OR ,P-OFLAG ,P-MERGED ,P-AND>
                     <PRINTB <COND (,P-NAM ,P-NAM)
                              (,P-ADJ ,P-ADJN)
                              (ELSE ,W?ONE)>>)
                       (ELSE
                     <THING-PRINT <EQUAL? .TBL ,P-PRSO>>)>
                 <TELL " do you mean, ">
                 <REPEAT ()
                     <SET TLEN <+ .TLEN 1>>
                     <SET OBJ <GET .TBL .TLEN>>
                     <TELL "the " D .OBJ>
                     <COND (<EQUAL? .LEN 2>
                            <COND (<NOT <EQUAL? .RLEN 2>> <TELL ",">)>
                            <TELL " or ">)
                           (<G? .LEN 2> <TELL ", ">)>
                     <COND (<L? <SET LEN <- .LEN 1>> 1>
                            <TELL "?" CR>
                            <RETURN>)>>>
        """)
    }

    func testThingPrint() throws {
        XCTAssertNoDifference(
            Game.routines.find("thingPrint"),
            Statement(
                id: "thingPrint",
                code: """
                    /// The `thingPrint` (THING-PRINT) routine.
                    func thingPrint(isPrso: Bool, isThe: Bool = false) throws {
                        var beg: Table?
                        var end: Table?
                        if isPrso {
                            beg.set(to: try Globals.pItbl.get(at: Constants.pNc1))
                            end.set(to: try Globals.pItbl.get(at: Constants.pNc1L))
                        } else {
                            beg.set(to: try Globals.pItbl.get(at: Constants.pNc2))
                            end.set(to: try Globals.pItbl.get(at: Constants.pNc2L))
                        }
                        try bufferPrint(beg: beg, end: end, cp: isThe)
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }

    func testWhichPrint() throws {
        XCTAssertNoDifference(
            Game.routines.find("whichPrint"),
            Statement(
                id: "whichPrint",
                code: """
                    /// The `whichPrint` (WHICH-PRINT) routine.
                    func whichPrint(tlen: Int, len: Int, tbl: Table) throws {
                        var obj: Object?
                        var rlen = 0
                        var tlen = tlen
                        var len = len
                        rlen.set(to: len)
                        output("Which ")
                        if .or(
                            Globals.pOflag,
                            Globals.pMerged,
                            Globals.pAnd
                        ) {
                            output({
                                if let Globals.pNam {
                                    return Globals.pNam
                                } else if Globals.pAdj {
                                    return Globals.pAdjn
                                } else {
                                    return Word.one
                                }
                            }())
                        } else {
                            try thingPrint(isPrso: tbl.equals(Globals.pPrso))
                        }
                        output(" do you mean, ")
                        while true {
                            tlen.set(to: tlen.add(1))
                            obj.set(to: try tbl.get(at: tlen))
                            output("the ")
                            output(obj.description)
                            if len.equals(2) {
                                if .isNot(rlen.equals(2)) {
                                    output(",")
                                }
                                output(" or ")
                            } else if len.isGreaterThan(2) {
                                output(", ")
                            }
                            if len.set(to: len.subtract(1)).isLessThan(1) {
                                output("?")
                                break
                            }
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }
}
