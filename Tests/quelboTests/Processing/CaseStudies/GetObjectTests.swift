//
//  GetObjectTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 12/30/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GetObjectTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        SearchListTests().sharedSetUp()
        DoSlTests().sharedSetUp()
        GlobalCheckTests().sharedSetUp()
        OrphanTests().sharedSetUp()
        IsAccessibleTests().sharedSetUp()
        BufferPrintTests().sharedSetUp()
        WhichPrintTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <CONSTANT P-ALL 1>
            <CONSTANT P-INHIBIT 4>
            <CONSTANT P-NC1 6>
            <CONSTANT P-NC2 8>
            <CONSTANT P-ONE 2>
            <CONSTANT P-P1BITS 3>
            <CONSTANT P-P1OFF 5> ;"First part of speech bit mask in PSOFF byte"
            <CONSTANT P-PSOFF 4> ;"Offset to first part of speech"
            <CONSTANT SC 64>
            <CONSTANT SH 128>
            <CONSTANT SIR 32>
            <CONSTANT SOG 16>

            <GLOBAL LIT <>>
            <GLOBAL P-ADJN <>>
            <GLOBAL P-GETFLAGS 0>
            <GLOBAL P-PRSO <ITABLE NONE 50>>
            <GLOBAL PLAYER <>>
            <GLOBAL WINNER 0>

            <SETG ZORK-NUMBER 1>

            <OBJECT NOT-HERE-OBJECT
                (DESC "such thing" ;"[not here]")
                (ACTION NOT-HERE-OBJECT-F)>

            ;"Check whether word pointed at by PTR is the correct part of speech.
               The second argument is the part of speech (,PS?<part of speech>).  The
               3rd argument (,P1?<part of speech>), if given, causes the value
               for that part of speech to be returned."
            <ROUTINE WT? (PTR BIT "OPTIONAL" (B1 5) "AUX" (OFFS ,P-P1OFF) TYP)
                <COND (<BTST <SET TYP <GETB .PTR ,P-PSOFF>> .BIT>
                       <COND (<G? .B1 4> <RTRUE>)
                         (T
                          <SET TYP <BAND .TYP ,P-P1BITS>>
                          <COND (<NOT <EQUAL? .TYP .B1>> <SET OFFS <+ .OFFS 1>>)>
                          <GETB .PTR .OFFS>)>)>>

            <ROUTINE GET-OBJECT (TBL
                         "OPTIONAL" (VRB T)
                         "AUX" BITS LEN XBITS TLEN (GCHECK <>) (OLEN 0) OBJ)
                 <SET XBITS ,P-SLOCBITS>
                 <SET TLEN <GET .TBL ,P-MATCHLEN>>
                 <COND (<BTST ,P-GETFLAGS ,P-INHIBIT> <RTRUE>)>
                 <COND (<AND <NOT ,P-NAM> ,P-ADJ>
                    <COND (<WT? ,P-ADJN ,PS?OBJECT ,P1?OBJECT>
                           <SETG P-NAM ,P-ADJN>
                           <SETG P-ADJ <>>)
                          %<COND (<==? ,ZORK-NUMBER 3>
                              '(<SET BITS
                                 <WT? ,P-ADJN
                                  ,PS?DIRECTION ,P1?DIRECTION>>
                            <SETG P-ADJ <>>
                            <PUT .TBL ,P-MATCHLEN 1>
                            <PUT .TBL 1 ,INTDIR>
                            <SETG P-DIRECTION .BITS>
                            <RTRUE>))
                             (ELSE '(<NULL-F> T))>>)>
                 <COND (<AND <NOT ,P-NAM>
                         <NOT ,P-ADJ>
                         <NOT <EQUAL? ,P-GETFLAGS ,P-ALL>>
                         <ZERO? ,P-GWIMBIT>>
                    <COND (.VRB
                           <TELL
            "There seems to be a noun missing in that sentence!" CR>)>
                    <RFALSE>)>
                 <COND (<OR <NOT <EQUAL? ,P-GETFLAGS ,P-ALL>> <ZERO? ,P-SLOCBITS>>
                    <SETG P-SLOCBITS -1>)>
                 <SETG P-TABLE .TBL>
                 <PROG ()
                       <COND (.GCHECK <GLOBAL-CHECK .TBL>)
                         (T
                          <COND (,LIT
                             <FCLEAR ,PLAYER ,TRANSBIT>
                             <DO-SL ,HERE ,SOG ,SIR>
                             <FSET ,PLAYER ,TRANSBIT>)>
                          <DO-SL ,PLAYER ,SH ,SC>)>
                       <SET LEN <- <GET .TBL ,P-MATCHLEN> .TLEN>>
                       <COND (<BTST ,P-GETFLAGS ,P-ALL>)
                         (<AND <BTST ,P-GETFLAGS ,P-ONE>
                           <NOT <ZERO? .LEN>>>
                          <COND (<NOT <EQUAL? .LEN 1>>
                             <PUT .TBL 1 <GET .TBL <RANDOM .LEN>>>
                             <TELL "(How about the ">
                             <PRINTD <GET .TBL 1>>
                             <TELL "?)" CR>)>
                          <PUT .TBL ,P-MATCHLEN 1>)
                         (<OR <G? .LEN 1>
                          <AND <ZERO? .LEN> <NOT <EQUAL? ,P-SLOCBITS -1>>>>
                          <COND (<EQUAL? ,P-SLOCBITS -1>
                             <SETG P-SLOCBITS .XBITS>
                             <SET OLEN .LEN>
                             <PUT .TBL
                              ,P-MATCHLEN
                              <- <GET .TBL ,P-MATCHLEN> .LEN>>
                             <AGAIN>)
                            (T
                             <COND (<ZERO? .LEN> <SET LEN .OLEN>)>
                             <COND (<NOT <EQUAL? ,WINNER ,PLAYER>>
                                <CANT-ORPHAN>
                                <RFALSE>)
                               (<AND .VRB ,P-NAM>
                                <WHICH-PRINT .TLEN .LEN .TBL>
                                <SETG P-ACLAUSE
                                  <COND (<EQUAL? .TBL ,P-PRSO> ,P-NC1)
                                    (T ,P-NC2)>>
                                <SETG P-AADJ ,P-ADJ>
                                <SETG P-ANAM ,P-NAM>
                                <ORPHAN <> <>>
                                <SETG P-OFLAG T>)
                               (.VRB
                                <TELL
            "There seems to be a noun missing in that sentence!" CR>)>
                             <SETG P-NAM <>>
                             <SETG P-ADJ <>>
                             <RFALSE>)>)>
                       <COND (<AND <ZERO? .LEN> .GCHECK>
                          <COND (.VRB
                             ;"next added 1/2/85 by JW"
                             <SETG P-SLOCBITS .XBITS>
                             <COND (<OR ,LIT <VERB? TELL ;WHERE ;WHAT ;WHO>>
                                ;"Changed 6/10/83 - MARC"
                                <OBJ-FOUND ,NOT-HERE-OBJECT .TBL>
                                <SETG P-XNAM ,P-NAM>
                                <SETG P-XADJ ,P-ADJ>
                                <SETG P-XADJN ,P-ADJN>
                                <SETG P-NAM <>>
                                <SETG P-ADJ <>>
                                <SETG P-ADJN <>>
                                <RTRUE>)
                               (T <TELL "It's too dark to see!" CR>)>)>
                          <SETG P-NAM <>>
                          <SETG P-ADJ <>>
                          <RFALSE>)
                         (<ZERO? .LEN> <SET GCHECK T> <AGAIN>)>
                       <SETG P-SLOCBITS .XBITS>
                       <SETG P-NAM <>>
                       <SETG P-ADJ <>>
                       <RTRUE>>>
        """)
    }

//    func testPNam() throws {
//        XCTAssertNoDifference(
//            Game.globals.find("pNam"),
//            Statement(
//                id: "pNam",
//                code: "var pNam: [Word]",
//                type: .word.array.property.optional.tableElement,
//                category: .globals,
//                isCommittable: true,
//                isMutable: true
//            )
//        )
//    }

    func testGetObject() throws {
        XCTAssertNoDifference(
            Game.routines.find("getObject"),
            Statement(
                id: "getObject",
                code: """
                    @discardableResult
                    /// The `getObject` (GET-OBJECT) routine.
                    func getObject(tbl: Table, vrb: Bool = true) -> Bool {
                        // var bits: <Unknown>
                        var len = 0
                        var xbits = 0
                        var tlen = 0
                        var gcheck = false
                        var olen = 0
                        // var obj: <Unknown>
                        xbits.set(to: Global.pSlocbits)
                        tlen.set(to: try tbl.get(at: Global.pMatchlen))
                        if _ = .bitwiseCompare(Global.pGetflags, Constant.pInhiBit) {
                            return true
                        }
                        if _ = .and(
                            .isNot(Global.pNam),
                            .object("Global.pAdj")
                        ) {
                            if isWt(
                                ptr: Global.pAdjn,
                                bit: PartsOfSpeech.object,
                                b1: PartsOfSpeech.objectFirst
                            ) {
                                Global.pNam.set(to: Global.pAdjn)
                                Global.pAdj.set(to: nil)
                            } else if nullFunc() {
                                return true
                            }
                        }
                        if .and(
                            .isNot(Global.pNam),
                            .isNot(Global.pAdj),
                            .isNot(Global.pGetflags.equals(Constant.pAll)),
                            Global.pGwimBit.isFalse
                        ) {
                            if vrb {
                                output("There seems to be a noun missing in that sentence!")
                            }
                            return false
                        }
                        if .or(
                            .isNot(Global.pGetflags.equals(Constant.pAll)),
                            Global.pSlocbits.isZero
                        ) {
                            Global.pSlocbits.set(to: -1)
                        }
                        Global.pTable.set(to: tbl)
                        do {
                            if gcheck {
                                globalCheck(tbl: tbl)
                            } else {
                                if Global.lit {
                                    Global.player.isTransparent.set(false)
                                    doSl(
                                        obj: Global.here,
                                        bit1: Constant.sog,
                                        bit2: Constant.sir
                                    )
                                    Global.player.isTransparent.set(true)
                                }
                                doSl(
                                    obj: Global.player,
                                    bit1: Constant.sh,
                                    bit2: Constant.sc
                                )
                            }
                            len.set(to: .subtract(try tbl.get(at: Global.pMatchlen), tlen))
                            if _ = .bitwiseCompare(Global.pGetflags, Constant.pAll) {
                                // do nothing
                            } else if _ = .and(
                                .bitwiseCompare(Global.pGetflags, Constant.pOne),
                                .isNot(len.isZero)
                            ) {
                                if .isNot(len.equals(1)) {
                                    tbl.put(
                                        element: try tbl.get(at: .random(len)),
                                        at: 1
                                    )
                                    output("(How about the ")
                                    output(try tbl.get(at: 1).description)
                                    output("?)")
                                }
                                tbl.put(
                                    element: 1,
                                    at: Global.pMatchlen
                                )
                            } else if .or(
                                len.isGreaterThan(1),
                                .and(
                                    len.isZero,
                                    .isNot(Global.pSlocbits.equals(-1))
                                )
                            ) {
                                if Global.pSlocbits.equals(-1) {
                                    Global.pSlocbits.set(to: xbits)
                                    olen.set(to: len)
                                    tbl.put(
                                        element: .subtract(try tbl.get(at: Global.pMatchlen), len),
                                        at: Global.pMatchlen
                                    )
                                    continue
                                } else {
                                    if len.isZero {
                                        len.set(to: olen)
                                    }
                                    if .isNot(Global.winner.equals(Global.player)) {
                                        cantOrphan()
                                        return false
                                    } else if _ = .and(vrb, Global.pNam) {
                                        whichPrint(tlen: tlen, len: len, tbl: tbl)
                                        pAclause.set(to: {
                                            if tbl.equals(Global.pPrso) {
                                                return Constant.pNc1
                                            } else {
                                                return Constant.pNc2
                                            }
                                        }())
                                        pAadj.set(to: Global.pAdj)
                                        Global.pAnam.set(to: Global.pNam)
                                        orphan(d1: nil, d2: nil)
                                        Global.pOflag.set(to: true)
                                    } else if vrb {
                                        output("There seems to be a noun missing in that sentence!")
                                    }
                                    Global.pNam.set(to: nil)
                                    Global.pAdj.set(to: nil)
                                    return false
                                }
                            }
                            if .and(len.isZero, gcheck) {
                                if vrb {
                                    // "next added 1/2/85 by JW"
                                    Global.pSlocbits.set(to: xbits)
                                    if .or(Global.lit, isParsedVerb(.tell)) {
                                        // "Changed 6/10/83 - MARC"
                                        objFound(obj: Object.notHereObject, tbl: tbl)
                                        pXnam.set(to: Global.pNam)
                                        pXadj.set(to: Global.pAdj)
                                        pXadjn.set(to: Global.pAdjn)
                                        Global.pNam.set(to: nil)
                                        Global.pAdj.set(to: nil)
                                        Global.pAdjn.set(to: nil)
                                        return true
                                    } else {
                                        output("It's too dark to see!")
                                    }
                                }
                                Global.pNam.set(to: nil)
                                Global.pAdj.set(to: nil)
                                return false
                            } else if len.isZero {
                                gcheck.set(to: true)
                                continue
                            }
                            Global.pSlocbits.set(to: xbits)
                            Global.pNam.set(to: nil)
                            Global.pAdj.set(to: nil)
                            return true
                        }
                    }
                    """,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
