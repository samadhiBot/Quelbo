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

    func testPGwimBit() throws {
        XCTAssertNoDifference(
            Game.globals.find("pGwimBit"),
            Statement(
                id: "pGwimBit",
                code: """
                    /// The `pGwimBit` (P-GWIMBIT) 􀎠Bool global.
                    var pGwimBit = false
                    """,
                type: .bool.optional,
                category: .globals,
                isCommittable: true,
                isMutable: true
            )
        )
    }

    func testIsThisIt() throws {
        XCTAssertNoDifference(
            Game.routines.find("isThisIt"),
            Statement(
                id: "isThisIt",
                code: """
                    @discardableResult
                    /// The `isThisIt` (THIS-IT?) routine.
                    func isThisIt(obj: Object, tbl: Table) -> Bool {
                        var syns = [[String]]()
                        if obj.hasFlag(.isInvisible) {
                            return false
                        } else if .and(
                            Globals.pNam,
                            .isNot(zmemq(
                                itm: Globals.pNam,
                                tbl: syns.set(to: obj.synonyms),
                                size: syns.propertySize.divide(2).subtract(1)
                            ))
                        ) {
                            return false
                        } else if .and(
                            Globals.pAdj,
                            .or(
                                .isNot(syns.set(to: obj.adjectives)),
                                .isNot(zmemqb(
                                    itm: Globals.pAdj,
                                    tbl: syns,
                                    size: syns.propertySize.subtract(1)
                                ))
                            )
                        ) {
                            return false
                        } else if .and(
                            .isNot(Globals.pGwimBit.isFalse),
                            .isNot(obj.hasFlag(.pGwimBit))
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
                    func objFound(obj: Object, tbl: Table) throws {
                        var ptr = 0
                        ptr.set(to: try tbl.get(at: Globals.pMatchlen))
                        try tbl.put(
                            element: obj,
                            at: ptr.add(1)
                        )
                        try tbl.put(
                            element: ptr.add(1),
                            at: Globals.pMatchlen
                        )
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

    func testSearchList() throws {
        XCTAssertNoDifference(
            Game.routines.find("searchList"),
            Statement(
                id: "searchList",
                code: """
                    /// The `searchList` (SEARCH-LIST) routine.
                    func searchList(obj: Object, tbl: Table, lvl: Int) throws {
                        // var fls: <Unknown>
                        var nobj: Object?
                        var obj = obj
                        if _ = obj.set(to: obj.firstChild) {
                            while true {
                                if _ = .and(
                                    .isNot(lvl.equals(Constants.pSrcbot)),
                                    obj.synonyms,
                                    isThisIt(obj: obj, tbl: tbl)
                                ) {
                                    try objFound(obj: obj, tbl: tbl)
                                }
                                if .and(
                                    .or(
                                        .isNot(lvl.equals(Constants.pSrctop)),
                                        obj.hasFlag(.isSearchable),
                                        obj.hasFlag(.isSurface)
                                    ),
                                    .object(nobj.set(to: obj.firstChild)),
                                    .or(
                                        obj.hasFlag(.isOpen),
                                        obj.hasFlag(.isTransparent)
                                    )
                                ) {
                                    fls.set(to: try searchList(
                                        obj: obj,
                                        tbl: tbl,
                                        lvl: {
                                            if obj.hasFlag(.isSurface) {
                                                return Constants.pSrcall
                                            } else if obj.hasFlag(.isSearchable) {
                                                return Constants.pSrcall
                                            } else {
                                                return Constants.pSrctop
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
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }
}
