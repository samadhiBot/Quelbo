//
//  SearchListTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SearchListTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <CONSTANT P-SRCALL 1>
            <CONSTANT P-SRCBOT 2>
            <CONSTANT P-SRCTOP 0>

            <GLOBAL P-ADJ <>>
            <GLOBAL P-GWIMBIT 0>
            <GLOBAL P-MATCHLEN 0>
            <GLOBAL P-NAM <>>

            <ROUTINE THIS-IT? (OBJ TBL "AUX" SYNS)
                <COND (<FSET? .OBJ ,INVISIBLE> <RFALSE>)
                        (<AND ,P-NAM
                        <NOT <ZMEMQ ,P-NAM
                            <SET SYNS <GETPT .OBJ ,P?SYNONYM>>
                            <- </ <PTSIZE .SYNS> 2> 1>>>>
                    <RFALSE>)
                        (<AND ,P-ADJ
                        <OR <NOT <SET SYNS <GETPT .OBJ ,P?ADJECTIVE>>>
                        <NOT <ZMEMQB ,P-ADJ .SYNS <- <PTSIZE .SYNS> 1>>>>>
                    <RFALSE>)
                        (<AND <NOT <ZERO? ,P-GWIMBIT>> <NOT <FSET? .OBJ ,P-GWIMBIT>>>
                    <RFALSE>)>
                <RTRUE>>

            <ROUTINE OBJ-FOUND (OBJ TBL "AUX" PTR)
                <SET PTR <GET .TBL ,P-MATCHLEN>>
                <PUT .TBL <+ .PTR 1> .OBJ>
                <PUT .TBL ,P-MATCHLEN <+ .PTR 1>>>

            <ROUTINE SEARCH-LIST (OBJ TBL LVL "AUX" FLS NOBJ)
                <COND (<SET OBJ <FIRST? .OBJ>>
                       <REPEAT ()
                           <COND (<AND <NOT <EQUAL? .LVL ,P-SRCBOT>>
                               <GETPT .OBJ ,P?SYNONYM>
                               <THIS-IT? .OBJ .TBL>>
                              <OBJ-FOUND .OBJ .TBL>)>
                           <COND (<AND <OR <NOT <EQUAL? .LVL ,P-SRCTOP>>
                                   <FSET? .OBJ ,SEARCHBIT>
                                   <FSET? .OBJ ,SURFACEBIT>>
                               <SET NOBJ <FIRST? .OBJ>>
                               <OR <FSET? .OBJ ,OPENBIT>
                                   <FSET? .OBJ ,TRANSBIT>>>
                              <SET FLS
                               <SEARCH-LIST .OBJ
                                    .TBL
                                    <COND (<FSET? .OBJ ,SURFACEBIT>
                                           ,P-SRCALL)
                                          (<FSET? .OBJ ,SEARCHBIT>
                                           ,P-SRCALL)
                                          (T ,P-SRCTOP)>>>)>
                           <COND (<SET OBJ <NEXT? .OBJ>>) (T <RETURN>)>>)>>
        """)
    }

    func testIsThisIt() throws {
        XCTAssertNoDifference(
            Game.routines.find("isThisIt"),
            Statement(
                id: "isThisIt",
                code: """
                    @discardableResult
                    /// The `isThisIt` (THIS-IT?) routine.
                    func isThisIt(
                        obj: Object,
                        tbl: Table
                    ) -> Bool {
                        var syns: [String] = []
                        if obj.hasFlag(isInvisible) {
                            return false
                        } else if .and(
                            pNam,
                            .isNot(zmemq(
                                itm: pNam,
                                tbl: syns.set(to: obj.synonyms),
                                size: .subtract(
                                    .divide(syns.propertySize, 2),
                                    1
                                )
                            ))
                        ) {
                            return false
                        } else if .and(
                            pAdj,
                            .or(
                                .isNot(syns.set(to: obj.adjectives)),
                                .isNot(zmemqb(
                                    itm: pAdj,
                                    tbl: syns,
                                    size: .subtract(syns.propertySize, 1)
                                ))
                            )
                        ) {
                            return false
                        } else if .and(
                            .isNot(pGwimBit.isFalse),
                            .isNot(obj.hasFlag(pGwimBit))
                        ) {
                            return false
                        }
                        return true
                    }
                    """,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testObjFound() throws {
        XCTAssertNoDifference(
            Game.routines.find("objFound"),
            Statement(
                id: "objFound",
                code: """
                    /// The `objFound` (OBJ-FOUND) routine.
                    func objFound(
                        obj: Object,
                        tbl: Table
                    ) {
                        var ptr: Int = 0
                        ptr.set(to: try tbl.get(at: pMatchlen))
                        try tbl.put(element: obj, at: .add(ptr, 1))
                        try tbl.put(element: .add(ptr, 1), at: pMatchlen)
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testSearchList() throws {
        XCTAssertNoDifference(
            Game.routines.find("searchList"),
            Statement(
                id: "searchList",
                code: """
                    /// The `searchList` (SEARCH-LIST) routine.
                    func searchList(
                        obj: Object,
                        tbl: Table,
                        lvl: Int
                    ) {
                        // var fls: <Unknown>
                        var nobj: Object? = nil
                        var obj: Object = obj
                        if _ = obj.set(to: obj.firstChild) {
                            while true {
                                if _ = .and(
                                    .isNot(lvl.equals(pSrcbot)),
                                    obj.synonyms,
                                    isThisIt(obj: obj, tbl: tbl)
                                ) {
                                    objFound(obj: obj, tbl: tbl)
                                }
                                if .and(
                                    .or(
                                        .isNot(lvl.equals(pSrctop)),
                                        obj.hasFlag(isSearchable),
                                        obj.hasFlag(isSurface)
                                    ),
                                    nobj.set(to: obj.firstChild),
                                    .or(
                                        obj.hasFlag(isOpen),
                                        obj.hasFlag(isTransparent)
                                    )
                                ) {
                                    fls.set(to: searchList(
                                        obj: obj,
                                        tbl: tbl,
                                        lvl: {
                                            if obj.hasFlag(isSurface) {
                                                return pSrcall
                                            } else if obj.hasFlag(isSearchable) {
                                                return pSrcall
                                            } else {
                                                return pSrctop
                                            }
                                        }()
                                    ))
                                }
                                if _ = obj.set(to: obj.nextSibling) {
                                    // do nothing
                                } else {
                                    break
                                }
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
}
