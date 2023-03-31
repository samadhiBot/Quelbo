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

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        IsAccessibleTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <CONSTANT P-WORDLEN 4> ;"Offset to parts of speech byte"

            <GLOBAL P-INBUF <ITABLE 120 (BYTE LENGTH) 0> ;<ITABLE BYTE 60>>
            <GLOBAL P-IT-OBJECT <>>
            <GLOBAL P-MERGED <>>
            <GLOBAL P-NUMBER 0>
            <GLOBAL P-OFLAG <>>

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

    func testWordPrint() throws {
        XCTAssertNoDifference(
            Game.routines.find("wordPrint"),
            Statement(
                id: "wordPrint",
                code: """
                    /// The `wordPrint` (WORD-PRINT) routine.
                    func wordPrint(cnt: Int, buf: Int) {
                        var cnt = cnt
                        var buf = buf
                        while true {
                            if cnt.decrement().isLessThan(0) {
                                break
                            } else {
                                output(try Globals.pInbuf.get(at: buf))
                                buf.set(to: buf.add(1))
                            }
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

    func testBufferPrint() throws {
        XCTAssertNoDifference(
            Game.routines.find("bufferPrint"),
            Statement(
                id: "bufferPrint",
                code: """
                    /// The `bufferPrint` (BUFFER-PRINT) routine.
                    func bufferPrint(beg: Table, end: Table, cp: Bool) throws {
                        var nosp = true
                        var wrd: Word?
                        var isFirst = true
                        var pn = false
                        var isQ = false
                        var beg = beg
                        while true {
                            if beg.equals(end) {
                                break
                            } else {
                                wrd.set(to: try beg.get(at: 0))
                                if wrd.equals(Word.comma) {
                                    output(", ")
                                } else if nosp {
                                    nosp.set(to: false)
                                } else {
                                    output(" ")
                                }
                                if wrd.equals(Word.period, Word.comma) {
                                    nosp.set(to: true)
                                } else if wrd.equals(Word.me) {
                                    output(Objects.me.description)
                                    pn.set(to: true)
                                } else if wrd.equals(Word.intnum) {
                                    output(Globals.pNumber)
                                    pn.set(to: true)
                                } else {
                                    if .and(isFirst, .isNot(pn), cp) {
                                        output("the ")
                                    }
                                    if .or(Globals.pOflag, Globals.pMerged) {
                                        output(wrd)
                                    } else if .and(
                                        wrd.equals(Word.it),
                                        isAccessible(obj: Globals.pItObject)
                                    ) {
                                        output(Globals.pItObject.description)
                                    } else {
                                        wordPrint(
                                            cnt: try beg.get(at: 2),
                                            buf: try beg.get(at: 3)
                                        )
                                    }
                                    isFirst.set(to: false)
                                }
                            }
                            beg.set(to: beg.rest(bytes: Constants.pWordlen))
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
