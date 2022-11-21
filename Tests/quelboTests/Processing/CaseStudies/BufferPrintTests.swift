//
//  BufferPrintTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/5/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class BufferPrintTests: QuelboTests {
    override func setUp() {
        super.setUp()
        IsAccessibleTests().setUp()

        process("""
            <CONSTANT P-WORDLEN 4> ;"Offset to parts of speech byte"
            <GLOBAL P-NUMBER 0>
            <GLOBAL P-OFLAG <>>
            <GLOBAL P-MERGED <>>
            <GLOBAL P-IT-OBJECT <>>
            <GLOBAL P-INBUF <ITABLE 120 (BYTE LENGTH) 0> ;<ITABLE BYTE 60>>

            <OBJECT ME
                (IN GLOBAL-OBJECTS)
                (SYNONYM ME MYSELF SELF CRETIN)
                (DESC "you")
                (FLAGS ACTORBIT)
                (ACTION CRETIN-FCN)>

            <ROUTINE WORD-PRINT (CNT BUF)
                 <REPEAT ()
                     <COND (<DLESS? CNT 0> <RETURN>)
                           (ELSE
                        <PRINTC <GETB ,P-INBUF .BUF>>
                        <SET BUF <+ .BUF 1>>)>>>

            <ROUTINE BUFFER-PRINT (BEG END CP
                           "AUX" (NOSP T) WRD (FIRST?? T) (PN <>) (Q? <>))
                 <REPEAT ()
                    <COND (<EQUAL? .BEG .END> <RETURN>)
                          (T
                           <SET WRD <GET .BEG 0>>
                           <COND ;(<EQUAL? .WRD ,W?$BUZZ> T)
                             (<EQUAL? .WRD ,W?COMMA>
                              <TELL ", ">)
                             (.NOSP <SET NOSP <>>)
                             (ELSE <TELL " ">)>
                           <COND (<EQUAL? .WRD ,W?PERIOD ,W?COMMA>
                              <SET NOSP T>)
                             (<EQUAL? .WRD ,W?ME>
                              <PRINTD ,ME>
                              <SET PN T>)
                             (<EQUAL? .WRD ,W?INTNUM>
                              <PRINTN ,P-NUMBER>
                              <SET PN T>)
                             (T
                              <COND (<AND .FIRST?? <NOT .PN> .CP>
                                 <TELL "the ">)>
                              <COND (<OR ,P-OFLAG ,P-MERGED> <PRINTB .WRD>)
                                (<AND <EQUAL? .WRD ,W?IT>
                                  <ACCESSIBLE? ,P-IT-OBJECT>>
                                 <PRINTD ,P-IT-OBJECT>)
                                (T
                                 <WORD-PRINT <GETB .BEG 2>
                                     <GETB .BEG 3>>)>
                              <SET FIRST?? <>>)>)>
                    <SET BEG <REST .BEG ,P-WORDLEN>>>>
        """)
    }

    func testBufferPrint() throws {
        XCTAssertNoDifference(
            Game.routines.find("bufferPrint"),
            Statement(
                id: "bufferPrint",
                code: """
                    @discardableResult
                    /// The `bufferPrint` (BUFFER-PRINT) routine.
                    func bufferPrint(
                        beg: Table,
                        end: Table,
                        cp: Any
                    ) -> Table {
                        var nosp: Bool = true
                        var wrd: Int = 0
                        var isFirst?: Bool = true
                        var pn: Bool = false
                        var isQ: Bool = false
                        var beg: Table = beg
                        while true {
                            if beg.equals(end) {
                                break
                            } else {
                                wrd.set(to: try beg.get(at: 0))
                                if wrd.equals(COMMA) {
                                    output(", ")
                                } else if nosp {
                                    nosp.set(to: false)
                                } else {
                                    output(" ")
                                }
                                if wrd.equals(PERIOD, COMMA) {
                                    nosp.set(to: true)
                                } else if wrd.equals(ME) {
                                    output(me.description)
                                    pn.set(to: true)
                                } else if wrd.equals(INTNUM) {
                                    output(pNumber)
                                    pn.set(to: true)
                                } else {
                                    if .and(
                                        isFirst?,
                                        .isNot(pn),
                                        cp
                                    ) {
                                        output("the ")
                                    }
                                    if .or(pOflag, pMerged) {
                                        output(wrd)
                                    } else if .and(
                                        wrd.equals(IT),
                                        isAccessible(obj: pItObject)
                                    ) {
                                        output(pItObject.description)
                                    } else {
                                        wordPrint(
                                            cnt: try beg.get(at: 2),
                                            buf: try beg.get(at: 3)
                                        )
                                    }
                                    isFirst?.set(to: false)
                                }
                            }
                            return beg.set(to: beg.rest(pWordlen))
                        }
                    }
                    """,
                type: .table,
                category: .routines,
                isCommittable: true
            )
        )
    }
}
