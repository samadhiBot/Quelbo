//
//  SnarfemTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 12/30/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SnarfemTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GetObjectTests().setUp()

        process("""
            <CONSTANT P-LEXELEN 2>
            <CONSTANT P-WORDLEN 4> ;"Offset to parts of speech byte"

            <GLOBAL P-AND <>>
            <GLOBAL P-BUTS <ITABLE NONE 50>>
            <GLOBAL P-ONEOBJ 0>

            <ROUTINE SNARFEM (PTR EPTR TBL "AUX" (BUT <>) LEN WV WRD NW (WAS-ALL <>))
               <SETG P-AND <>>
               <COND (<EQUAL? ,P-GETFLAGS ,P-ALL>
                  <SET WAS-ALL T>)>
               <SETG P-GETFLAGS 0>
               <PUT .TBL ,P-MATCHLEN 0>
               <SET WRD <GET .PTR 0>>
               <REPEAT ()
                   <COND (<EQUAL? .PTR .EPTR>
                      <SET WV <GET-OBJECT <OR .BUT .TBL>>>
                      <COND (.WAS-ALL <SETG P-GETFLAGS ,P-ALL>)>
                      <RETURN .WV>)
                     (T
                      <COND (<==? .EPTR <REST .PTR ,P-WORDLEN>>
                         <SET NW 0>)
                        (T <SET NW <GET .PTR ,P-LEXELEN>>)>
                      <COND (<EQUAL? .WRD ,W?ALL ;,W?BOTH>
                         <SETG P-GETFLAGS ,P-ALL>
                         <COND (<EQUAL? .NW ,W?OF>
                            <SET PTR <REST .PTR ,P-WORDLEN>>)>)
                        (<EQUAL? .WRD ,W?BUT ,W?EXCEPT>
                         <OR <GET-OBJECT <OR .BUT .TBL>> <RFALSE>>
                         <SET BUT ,P-BUTS>
                         <PUT .BUT ,P-MATCHLEN 0>)
                        (<EQUAL? .WRD ,W?A ,W?ONE>
                         <COND (<NOT ,P-ADJ>
                            <SETG P-GETFLAGS ,P-ONE>
                            <COND (<EQUAL? .NW ,W?OF>
                                   <SET PTR <REST .PTR ,P-WORDLEN>>)>)
                               (T
                            <SETG P-NAM ,P-ONEOBJ>
                            <OR <GET-OBJECT <OR .BUT .TBL>> <RFALSE>>
                            <AND <ZERO? .NW> <RTRUE>>)>)
                        (<AND <EQUAL? .WRD ,W?AND ,W?COMMA>
                              <NOT <EQUAL? .NW ,W?AND ,W?COMMA>>>
                         <SETG P-AND T>
                         <OR <GET-OBJECT <OR .BUT .TBL>> <RFALSE>>
                         T)
                        (<WT? .WRD ,PS?BUZZ-WORD>)
                        (<EQUAL? .WRD ,W?AND ,W?COMMA>)
                        (<EQUAL? .WRD ,W?OF>
                         <COND (<ZERO? ,P-GETFLAGS>
                            <SETG P-GETFLAGS ,P-INHIBIT>)>)
                        (<AND <SET WV <WT? .WRD ,PS?ADJECTIVE ,P1?ADJECTIVE>>
                              <NOT ,P-ADJ>>
                         <SETG P-ADJ .WV>
                         <SETG P-ADJN .WRD>)
                        (<WT? .WRD ,PS?OBJECT ,P1?OBJECT>
                         <SETG P-NAM .WRD>
                         <SETG P-ONEOBJ .WRD>)>)>
                   <COND (<NOT <EQUAL? .PTR .EPTR>>
                      <SET PTR <REST .PTR ,P-WORDLEN>>
                      <SET WRD .NW>)>>>
        """)
    }

    func testSnarfem() throws {
        XCTAssertNoDifference(
            Game.routines.find("snarfem"),
            Statement(
                id: "snarfem",
                code: """
                    @discardableResult
                    /// The `snarfem` (SNARFEM) routine.
                    func snarfem(
                        ptr: Table,
                        eptr: Table,
                        tbl: Table
                    ) -> Bool {
                        var but: Table? = nil
                        // var len: <Unknown>
                        var wv: Bool = false
                        var wrd: Int = 0
                        var nw: Word? = nil
                        var wasAll: Bool = false
                        var ptr: Table = ptr
                        pAnd.set(to: false)
                        if pGetflags.equals(pAll) {
                            wasAll.set(to: true)
                        }
                        pGetflags.set(to: 0)
                        try tbl.put(element: 0, at: pMatchlen)
                        wrd.set(to: try ptr.get(at: 0))
                        while true {
                            if ptr.equals(eptr) {
                                wv.set(to: getObject(tbl: .or(but, tbl)))
                                if wasAll {
                                    pGetflags.set(to: pAll)
                                }
                                return wv
                            } else {
                                if eptr.equals(
                                    ptr.rest(bytes: pWordlen)
                                ) {
                                    nw.set(to: nil)
                                } else {
                                    nw.set(to: try ptr.get(at: pLexelen))
                                }
                                if wrd.equals(Word.all, // ,W?BOTH) {
                                    pGetflags.set(to: pAll)
                                    if nw.equals(Word.of) {
                                        ptr.set(to: ptr.rest(bytes: pWordlen))
                                    }
                                } else if wrd.equals(Word.but, Word.except) {
                                    .or(
                                        getObject(tbl: .or(but, tbl)),
                                        return false
                                    )
                                    but.set(to: pButs)
                                    try but.put(element: 0, at: pMatchlen)
                                } else if wrd.equals(Word.a, Word.one) {
                                    if .isNot(pAdj) {
                                        pGetflags.set(to: pOne)
                                        if nw.equals(Word.of) {
                                            ptr.set(to: ptr.rest(bytes: pWordlen))
                                        }
                                    } else {
                                        pNam.set(to: pOneobj)
                                        .or(
                                            getObject(tbl: .or(but, tbl)),
                                            return false
                                        )
                                        .and(
                                            nw.isZero,
                                            return true
                                        )
                                    }
                                } else if .and(
                                    wrd.equals(Word.and, Word.comma),
                                    .isNot(nw.equals(Word.and, Word.comma))
                                ) {
                                    pAnd.set(to: true)
                                    .or(
                                        getObject(tbl: .or(but, tbl)),
                                        return false
                                    )
                                    return true
                                } else if isWt(
                                    ptr: wrd,
                                    bit: PartsOfSpeech.buzzWord
                                ) {
                                    // do nothing
                                } else if wrd.equals(Word.and, Word.comma) {
                                    // do nothing
                                } else if wrd.equals(Word.of) {
                                    if pGetflags.isZero {
                                        pGetflags.set(to: pInhiBit)
                                    }
                                } else if _ = .and(
                                    wv.set(to: isWt(
                                        ptr: wrd,
                                        bit: PartsOfSpeech.adjective,
                                        b1: PartsOfSpeech.adjective
                                    )),
                                    .isNot(pAdj)
                                ) {
                                    pAdj.set(to: wv)
                                    pAdjn.set(to: wrd)
                                } else if _ = isWt(
                                    ptr: wrd,
                                    bit: PartsOfSpeech.object,
                                    b1: PartsOfSpeech.object
                                ) {
                                    pNam.set(to: wrd)
                                    pOneobj.set(to: wrd)
                                }
                            }
                            if .isNot(ptr.equals(eptr)) {
                                ptr.set(to: ptr.rest(bytes: pWordlen))
                                wrd.set(to: nw)
                            }
                        }
                    }
                    """,
                type: .bool,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
