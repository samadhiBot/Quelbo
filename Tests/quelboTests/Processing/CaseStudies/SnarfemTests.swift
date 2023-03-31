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

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        SearchListTests().sharedSetUp()
        DoSlTests().sharedSetUp()
        IsLitTests().sharedSetUp()
        GlobalCheckTests().sharedSetUp()
        OrphanTests().sharedSetUp()
        IsAccessibleTests().sharedSetUp()
        BufferPrintTests().sharedSetUp()
        NotHereTests().sharedSetUp()
        WhichPrintTests().sharedSetUp()
        GetObjectTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <CONSTANT P-LEXELEN 2>
            <CONSTANT P-SLOC1 5>
            <CONSTANT P-SLOC2 6>
            <CONSTANT P-WORDLEN 4> ;"Offset to parts of speech byte"

            <GLOBAL P-AND <>>
            <GLOBAL P-BUTS <ITABLE NONE 50>>
            <GLOBAL P-ONEOBJ 0>
            <GLOBAL P-SYNTAX 0>

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

            <ROUTINE BUT-MERGE (TBL "AUX" LEN BUTLEN (CNT 1) (MATCHES 0) OBJ NTBL)
                <SET LEN <GET .TBL ,P-MATCHLEN>>
                <PUT ,P-MERGE ,P-MATCHLEN 0>
                <REPEAT ()
                    <COND (<DLESS? LEN 0> <RETURN>)
                          (<ZMEMQ <SET OBJ <GET .TBL .CNT>> ,P-BUTS>)
                          (T
                           <PUT ,P-MERGE <+ .MATCHES 1> .OBJ>
                           <SET MATCHES <+ .MATCHES 1>>)>
                    <SET CNT <+ .CNT 1>>>
                <PUT ,P-MERGE ,P-MATCHLEN .MATCHES>
                <SET NTBL ,P-MERGE>
                <SETG P-MERGE .TBL>
                .NTBL>

            <ROUTINE SNARF-OBJECTS ("AUX" OPTR IPTR L)
                 <PUT ,P-BUTS ,P-MATCHLEN 0>
                 <COND (<NOT <EQUAL? <SET IPTR <GET ,P-ITBL ,P-NC2>> 0>>
                    <SETG P-SLOCBITS <GETB ,P-SYNTAX ,P-SLOC2>>
                    <OR <SNARFEM .IPTR <GET ,P-ITBL ,P-NC2L> ,P-PRSI> <RFALSE>>)>
                 <COND (<NOT <EQUAL? <SET OPTR <GET ,P-ITBL ,P-NC1>> 0>>
                    <SETG P-SLOCBITS <GETB ,P-SYNTAX ,P-SLOC1>>
                    <OR <SNARFEM .OPTR <GET ,P-ITBL ,P-NC1L> ,P-PRSO> <RFALSE>>)>
                 <COND (<NOT <ZERO? <GET ,P-BUTS ,P-MATCHLEN>>>
                    <SET L <GET ,P-PRSO ,P-MATCHLEN>>
                    <COND (.OPTR <SETG P-PRSO <BUT-MERGE ,P-PRSO>>)>
                    <COND (<AND .IPTR
                            <OR <NOT .OPTR>
                            <EQUAL? .L <GET ,P-PRSO ,P-MATCHLEN>>>>
                           <SETG P-PRSI <BUT-MERGE ,P-PRSI>>)>)>
                 <RTRUE>>
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
                    func snarfem(ptr: Table, eptr: Table, tbl: Table) throws -> Bool {
                        var but: Table?
                        // var len: <Unknown>
                        var wv = false
                        var wrd = [[Word]]()
                        var nw = [[Word]]()
                        var wasAll = false
                        var ptr = ptr
                        Globals.pAnd.set(to: false)
                        if Globals.pGetflags.equals(Constants.pAll) {
                            wasAll.set(to: true)
                        }
                        Globals.pGetflags.set(to: 0)
                        try tbl.put(
                            element: 0,
                            at: Globals.pMatchlen
                        )
                        wrd.set(to: try ptr.get(at: 0))
                        while true {
                            if ptr.equals(eptr) {
                                wv.set(to: try getObject(tbl: .or(but, tbl)))
                                if wasAll {
                                    Globals.pGetflags.set(to: Constants.pAll)
                                }
                                return wv
                            } else {
                                if eptr.equals(ptr.rest(bytes: Constants.pWordlen)) {
                                    nw.set(to: nil)
                                } else {
                                    nw.set(to: try ptr.get(at: Constants.pLexelen))
                                }
                                if wrd.equals(Word.all) {
                                    Globals.pGetflags.set(to: Constants.pAll)
                                    if nw.equals(Word.of) {
                                        ptr.set(to: ptr.rest(bytes: Constants.pWordlen))
                                    }
                                } else if wrd.equals(Word.but, Word.except) {
                                    .or(
                                        try getObject(tbl: .or(but, tbl)),
                                        return false
                                    )
                                    but.set(to: Globals.pButs)
                                    try but.put(
                                        element: 0,
                                        at: Globals.pMatchlen
                                    )
                                } else if wrd.equals(Word.a, Word.one) {
                                    if .isNot(Globals.pAdj) {
                                        Globals.pGetflags.set(to: Constants.pOne)
                                        if nw.equals(Word.of) {
                                            ptr.set(to: ptr.rest(bytes: Constants.pWordlen))
                                        }
                                    } else {
                                        Globals.pNam.set(to: Globals.pOneobj)
                                        .or(
                                            try getObject(tbl: .or(but, tbl)),
                                            return false
                                        )
                                        .and(nw.isNil, return true)
                                    }
                                } else if .and(
                                    wrd.equals(Word.and, Word.comma),
                                    .isNot(nw.equals(Word.and, Word.comma))
                                ) {
                                    Globals.pAnd.set(to: true)
                                    .or(
                                        try getObject(tbl: .or(but, tbl)),
                                        return false
                                    )
                                    return true
                                } else if try isWt(ptr: wrd, bit: PartsOfSpeech.buzzWord) {
                                    // do nothing
                                } else if wrd.equals(Word.and, Word.comma) {
                                    // do nothing
                                } else if wrd.equals(Word.of) {
                                    if Globals.pGetflags.isZero {
                                        Globals.pGetflags.set(to: Constants.pInhiBit)
                                    }
                                } else if .and(
                                    wv.set(to: try isWt(
                                        ptr: wrd,
                                        bit: PartsOfSpeech.adjective,
                                        b1: PartsOfSpeech.adjectiveFirst
                                    )),
                                    .isNot(Globals.pAdj)
                                ) {
                                    Globals.pAdj.set(to: wv)
                                    Globals.pAdjn.set(to: wrd)
                                } else if try isWt(
                                    ptr: wrd,
                                    bit: PartsOfSpeech.object,
                                    b1: PartsOfSpeech.objectFirst
                                ) {
                                    Globals.pNam.set(to: wrd)
                                    Globals.pOneobj.set(to: wrd)
                                }
                            }
                            if .isNot(ptr.equals(eptr)) {
                                ptr.set(to: ptr.rest(bytes: Constants.pWordlen))
                                wrd.set(to: nw)
                            }
                        }
                    }
                    """,
                type: .bool,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }

    func testButMerge() throws {
        XCTAssertNoDifference(
            Game.routines.find("butMerge"),
            Statement(
                id: "butMerge",
                code: """
                    @discardableResult
                    /// The `butMerge` (BUT-MERGE) routine.
                    func butMerge(tbl: Table) throws -> Table? {
                        var len = 0
                        // var butlen: <Unknown>
                        var cnt = 1
                        var matches = 0
                        var obj = [[Object]]()
                        var ntbl: Table?
                        len.set(to: try tbl.get(at: Globals.pMatchlen))
                        try Globals.pMerge.put(
                            element: 0,
                            at: Globals.pMatchlen
                        )
                        while true {
                            if len.decrement().isLessThan(0) {
                                break
                            } else if _ = zmemq(
                                itm: obj.set(to: try tbl.get(at: cnt)),
                                tbl: Globals.pButs
                            ) {
                                // do nothing
                            } else {
                                try Globals.pMerge.put(
                                    element: obj,
                                    at: matches.add(1)
                                )
                                matches.set(to: matches.add(1))
                            }
                            cnt.set(to: cnt.add(1))
                        }
                        try Globals.pMerge.put(
                            element: matches,
                            at: Globals.pMatchlen
                        )
                        ntbl.set(to: Globals.pMerge)
                        Globals.pMerge.set(to: tbl)
                        return ntbl
                    }
                    """,
                type: .table.root.optional,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }

    func testSnarfObjects() throws {
        XCTAssertNoDifference(
            Game.routines.find("snarfObjects"),
            Statement(
                id: "snarfObjects",
                code: """
                    @discardableResult
                    /// The `snarfObjects` (SNARF-OBJECTS) routine.
                    func snarfObjects() throws -> Bool {
                        var optr: Table?
                        var iptr: Table?
                        var l: TableElement?
                        try Globals.pButs.put(
                            element: 0,
                            at: Globals.pMatchlen
                        )
                        if .isNot(iptr.set(to: try Globals.pItbl.get(at: Constants.pNc2)).equals(nil)) {
                            Globals.pSlocbits.set(to: try Globals.pSyntax.get(at: Constants.pSloc2))
                            .or(
                                try snarfem(
                                    ptr: iptr,
                                    eptr: try Globals.pItbl.get(at: Constants.pNc2L),
                                    tbl: Globals.pPrsi
                                ),
                                return false
                            )
                        }
                        if .isNot(optr.set(to: try Globals.pItbl.get(at: Constants.pNc1)).equals(nil)) {
                            Globals.pSlocbits.set(to: try Globals.pSyntax.get(at: Constants.pSloc1))
                            .or(
                                try snarfem(
                                    ptr: optr,
                                    eptr: try Globals.pItbl.get(at: Constants.pNc1L),
                                    tbl: Globals.pPrso
                                ),
                                return false
                            )
                        }
                        if .isNot(try Globals.pButs.get(at: Globals.pMatchlen).isZero) {
                            l.set(to: try Globals.pPrso.get(at: Globals.pMatchlen))
                            if let optr {
                                Globals.pPrso.set(to: try butMerge(tbl: Globals.pPrso))
                            }
                            if _ = .and(
                                iptr,
                                .or(
                                    .isNot(optr),
                                    l.equals(
                                        try Globals.pPrso.get(at: Globals.pMatchlen)
                                    )
                                )
                            ) {
                                Globals.pPrsi.set(to: try butMerge(tbl: Globals.pPrsi))
                            }
                        }
                        return true
                    }
                    """,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }
}
