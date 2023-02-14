//
//  OrphanTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 12/31/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class OrphanTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        SearchListTests().sharedSetUp()
        DoSlTests().sharedSetUp()
        GlobalCheckTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process(#"""
            <CONSTANT CC-DBPTR 2>
            <CONSTANT CC-DEPTR 3>
            <CONSTANT CC-SBPTR 0>
            <CONSTANT CC-SEPTR 1>
            <CONSTANT P-ITBLLEN 9>
            <CONSTANT P-LEXELEN 2>
            <CONSTANT P-NC1 6>
            <CONSTANT P-NC1L 7>
            <CONSTANT P-NC2 8>
            <CONSTANT P-NC2L 9>
            <CONSTANT P-PREP1 2>
            <CONSTANT P-PREP2 4>
            <CONSTANT P-SPREP1 1>
            <CONSTANT P-SPREP2 2>
            <CONSTANT P-WORDLEN 4> ;"Offset to parts of speech byte"

            <GLOBAL P-ANAM <>>
            <GLOBAL P-CCTBL <TABLE 0 0 0 0>>
            <GLOBAL P-ITBL <TABLE 0 0 0 0 0 0 0 0 0 0>>
            <GLOBAL P-MATCHLEN 0>
            <GLOBAL P-MERGED <>>
            <GLOBAL P-NCN 0>
            <GLOBAL P-OCLAUSE <ITABLE NONE 100>>
            <GLOBAL P-OTBL <TABLE 0 0 0 0 0 0 0 0 0 0>>
            <GLOBAL P-OVTBL <TABLE 0 #BYTE 0 #BYTE 0>>
            <GLOBAL P-VTBL <TABLE 0 0 0 0>>

            <ROUTINE CLAUSE-ADD (WRD "AUX" PTR)
                <SET PTR <+ <GET ,P-OCLAUSE ,P-MATCHLEN> 2>>
                <PUT ,P-OCLAUSE <- .PTR 1> .WRD>
                <PUT ,P-OCLAUSE .PTR 0>
                <PUT ,P-OCLAUSE ,P-MATCHLEN .PTR>>

            <ROUTINE CLAUSE-COPY (SRC DEST "OPTIONAL" (INSRT <>) "AUX" BEG END)
                <SET BEG <GET .SRC <GET ,P-CCTBL ,CC-SBPTR>>>
                <SET END <GET .SRC <GET ,P-CCTBL ,CC-SEPTR>>>
                <PUT .DEST
                     <GET ,P-CCTBL ,CC-DBPTR>
                     <REST ,P-OCLAUSE
                       <+ <* <GET ,P-OCLAUSE ,P-MATCHLEN> ,P-LEXELEN> 2>>>
                <REPEAT ()
                    <COND (<EQUAL? .BEG .END>
                           <PUT .DEST
                            <GET ,P-CCTBL ,CC-DEPTR>
                            <REST ,P-OCLAUSE
                              <+ <* <GET ,P-OCLAUSE ,P-MATCHLEN> ,P-LEXELEN>
                                 2>>>
                           <RETURN>)
                          (T
                           <COND (<AND .INSRT <EQUAL? ,P-ANAM <GET .BEG 0>>>
                              <CLAUSE-ADD .INSRT>)>
                           <CLAUSE-ADD <GET .BEG 0>>)>
                    <SET BEG <REST .BEG ,P-WORDLEN>>>>

            <ROUTINE CANT-ORPHAN ()
                 <TELL "\"I don't understand! What are you referring to?\"" CR>
                 <RFALSE>>

            <ROUTINE ORPHAN (D1 D2 "AUX" (CNT -1))
                <COND (<NOT ,P-MERGED>
                       <PUT ,P-OCLAUSE ,P-MATCHLEN 0>)>
                <PUT ,P-OVTBL 0 <GET ,P-VTBL 0>>
                <PUTB ,P-OVTBL 2 <GETB ,P-VTBL 2>>
                <PUTB ,P-OVTBL 3 <GETB ,P-VTBL 3>>
                <REPEAT ()
                    <COND (<IGRTR? CNT ,P-ITBLLEN> <RETURN>)
                          (T <PUT ,P-OTBL .CNT <GET ,P-ITBL .CNT>>)>>
                <COND (<EQUAL? ,P-NCN 2>
                       <PUT ,P-CCTBL ,CC-SBPTR ,P-NC2>
                       <PUT ,P-CCTBL ,CC-SEPTR ,P-NC2L>
                       <PUT ,P-CCTBL ,CC-DBPTR ,P-NC2>
                       <PUT ,P-CCTBL ,CC-DEPTR ,P-NC2L>
                       <CLAUSE-COPY ,P-ITBL ,P-OTBL>)>
                <COND (<NOT <L? ,P-NCN 1>>
                       <PUT ,P-CCTBL ,CC-SBPTR ,P-NC1>
                       <PUT ,P-CCTBL ,CC-SEPTR ,P-NC1L>
                       <PUT ,P-CCTBL ,CC-DBPTR ,P-NC1>
                       <PUT ,P-CCTBL ,CC-DEPTR ,P-NC1L>
                       <CLAUSE-COPY ,P-ITBL ,P-OTBL>)>
                <COND (.D1
                       <PUT ,P-OTBL ,P-PREP1 <GETB .D1 ,P-SPREP1>>
                       <PUT ,P-OTBL ,P-NC1 1>)
                      (.D2
                       <PUT ,P-OTBL ,P-PREP2 <GETB .D2 ,P-SPREP2>>
                       <PUT ,P-OTBL ,P-NC2 1>)>>
        """#)
    }

    func testClauseAdd() throws {
        XCTAssertNoDifference(
            Game.routines.find("clauseAdd"),
            Statement(
                id: "clauseAdd",
                code: """
                    /// The `clauseAdd` (CLAUSE-ADD) routine.
                    func clauseAdd(wrd: Bool) {
                        var ptr: Int = 0
                        ptr.set(to: .add(
                            try pOclause.get(at: pMatchlen),
                            2
                        ))
                        try pOclause.put(element: wrd, at: .subtract(ptr, 1))
                        try pOclause.put(element: 0, at: ptr)
                        try pOclause.put(element: ptr, at: pMatchlen)
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testClauseCopy() throws {
        XCTAssertNoDifference(
            Game.routines.find("clauseCopy"),
            Statement(
                id: "clauseCopy",
                code: """
                    /// The `clauseCopy` (CLAUSE-COPY) routine.
                    func clauseCopy(
                        src: Table,
                        dest: Table,
                        insrt: Bool = false
                    ) {
                        var beg: Table? = nil
                        var end: Table? = nil
                        beg.set(to: try src.get(at: try pCctbl.get(at: ccSbptr)))
                        end.set(to: try src.get(at: try pCctbl.get(at: ccSeptr)))
                        try dest.put(element: pOclause.rest(bytes: .add(
                            .multiply(
                                try pOclause.get(at: pMatchlen),
                                pLexelen
                            ),
                            2
                        )), at: try pCctbl.get(at: ccDbptr))
                        while true {
                            if beg.equals(end) {
                                try dest.put(element: pOclause.rest(bytes: .add(
                                    .multiply(
                                        try pOclause.get(at: pMatchlen),
                                        pLexelen
                                    ),
                                    2
                                )), at: try pCctbl.get(at: ccDeptr))
                                break
                            } else {
                                if .and(
                                    insrt,
                                    pAnam.equals(try beg.get(at: 0))
                                ) {
                                    clauseAdd(wrd: insrt)
                                }
                                clauseAdd(
                                    wrd: try beg.get(at: 0)
                                )
                            }
                            beg.set(to: beg.rest(bytes: pWordlen))
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

    func testCantOrphan() throws {
        XCTAssertNoDifference(
            Game.routines.find("cantOrphan"),
            Statement(
                id: "cantOrphan",
                code: #"""
                    @discardableResult
                    /// The `cantOrphan` (CANT-ORPHAN) routine.
                    func cantOrphan() -> Bool {
                        output("\"I don't understand! What are you referring to?\"")
                        return false
                    }
                    """#,
                type: .booleanFalse,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testOrphan() throws {
        XCTAssertNoDifference(
            Game.routines.find("orphan"),
            Statement(
                id: "orphan",
                code: """
                    /// The `orphan` (ORPHAN) routine.
                    func orphan(d1: Table, d2: Table) {
                        var cnt: Int = -1
                        if .isNot(pMerged) {
                            try pOclause.put(element: 0, at: pMatchlen)
                        }
                        try pOvtbl.put(element: try pVtbl.get(at: 0), at: 0)
                        try pOvtbl.put(element: try pVtbl.get(at: 2), at: 2)
                        try pOvtbl.put(element: try pVtbl.get(at: 3), at: 3)
                        while true {
                            if cnt.increment().isGreaterThan(pItbllen) {
                                break
                            } else {
                                try pOtbl.put(element: try pItbl.get(at: cnt), at: cnt)
                            }
                        }
                        if pNcn.equals(2) {
                            try pCctbl.put(element: pNc2, at: ccSbptr)
                            try pCctbl.put(element: pNc2L, at: ccSeptr)
                            try pCctbl.put(element: pNc2, at: ccDbptr)
                            try pCctbl.put(element: pNc2L, at: ccDeptr)
                            clauseCopy(
                                src: pItbl,
                                dest: pOtbl
                            )
                        }
                        if .isNot(pNcn.isLessThan(1)) {
                            try pCctbl.put(element: pNc1, at: ccSbptr)
                            try pCctbl.put(element: pNc1L, at: ccSeptr)
                            try pCctbl.put(element: pNc1, at: ccDbptr)
                            try pCctbl.put(element: pNc1L, at: ccDeptr)
                            clauseCopy(
                                src: pItbl,
                                dest: pOtbl
                            )
                        }
                        if let d1 {
                            try pOtbl.put(element: try d1.get(at: pSprep1), at: pPrep1)
                            try pOtbl.put(element: 1, at: pNc1)
                        } else if let d2 {
                            try pOtbl.put(element: try d2.get(at: pSprep2), at: pPrep2)
                            try pOtbl.put(element: 1, at: pNc2)
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
}
