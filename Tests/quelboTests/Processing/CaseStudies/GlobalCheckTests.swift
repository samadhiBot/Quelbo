//
//  GlobalCheckTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 12/30/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GlobalCheckTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        SearchListTests().sharedSetUp()
        DoSlTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <OBJECT PSEUDO-OBJECT
                (IN LOCAL-GLOBALS)
                (DESC "pseudo")
                (ACTION CRETIN-FCN)>

            <OBJECT ROOMS (IN TO ROOMS)>

            <ROUTINE GLOBAL-CHECK (TBL "AUX" LEN RMG RMGL (CNT 0) OBJ OBITS FOO)
                <SET LEN <GET .TBL ,P-MATCHLEN>>
                <SET OBITS ,P-SLOCBITS>
                <COND (<SET RMG <GETPT ,HERE ,P?GLOBAL>>
                       <SET RMGL <- <PTSIZE .RMG> 1>>
                       <REPEAT ()
                           <COND (<THIS-IT? <SET OBJ <GETB .RMG .CNT>> .TBL>
                              <OBJ-FOUND .OBJ .TBL>)>
                           <COND (<IGRTR? CNT .RMGL> <RETURN>)>>)>
                <COND (<SET RMG <GETPT ,HERE ,P?PSEUDO>>
                       <SET RMGL <- </ <PTSIZE .RMG> 4> 1>>
                       <SET CNT 0>
                       <REPEAT ()
                           <COND (<EQUAL? ,P-NAM <GET .RMG <* .CNT 2>>>
                              <PUTP ,PSEUDO-OBJECT
                                ,P?ACTION
                                <GET .RMG <+ <* .CNT 2> 1>>>
                              <SET FOO
                               <BACK <GETPT ,PSEUDO-OBJECT ,P?ACTION> 5>>
                              <PUT .FOO 0 <GET ,P-NAM 0>>
                              <PUT .FOO 1 <GET ,P-NAM 1>>
                              <OBJ-FOUND ,PSEUDO-OBJECT .TBL>
                              <RETURN>)
                                 (<IGRTR? CNT .RMGL> <RETURN>)>>)>
                <COND (<EQUAL? <GET .TBL ,P-MATCHLEN> .LEN>
                       <SETG P-SLOCBITS -1>
                       <SETG P-TABLE .TBL>
                       <DO-SL ,GLOBAL-OBJECTS 1 1>
                       <SETG P-SLOCBITS .OBITS>
                       <COND (<AND <ZERO? <GET .TBL ,P-MATCHLEN>>
                           <EQUAL? ,PRSA ,V?LOOK-INSIDE ,V?SEARCH ,V?EXAMINE>>
                          <DO-SL ,ROOMS 1 1>)>)>>
        """)
    }

    func testPNam() throws {
        XCTAssertNoDifference(
            Game.globals.find("pNam"),
            Statement(
                id: "pNam",
                code: """
                    /// The `pNam` (P-NAM) 􀎠􀀢􀀪[Object] global.
                    var pNam: [Object]
                    """,
                type: .object.array.property.optional.tableElement,
                category: .globals,
                isCommittable: true,
                isMutable: true
            )
        )
    }

    func testPseudoObject() {
        XCTAssertNoDifference(
            Game.objects.find("pseudoObject"),
            Statement(
                id: "pseudoObject",
                code: """
                 /// The `pseudoObject` (PSEUDO-OBJECT) object.
                 var pseudoObject = Object(
                     id: "pseudoObject",
                     action: "cretinFunc",
                     description: "pseudo",
                     location: "localGlobals"
                 )
                 """,
                type: .object.array.property,
                category: .objects,
                isCommittable: true
            )
        )
    }

    func testGlobalCheck() throws {
        XCTAssertNoDifference(
            Game.routines.find("globalCheck"),
            Statement(
                id: "globalCheck",
                code: """
                    /// The `globalCheck` (GLOBAL-CHECK) routine.
                    func globalCheck(tbl: Table) throws {
                        var len: TableElement?
                        var rmg = [[Object]]()
                        var rmgl = 0
                        var cnt = 0
                        var obj = [[Object]]()
                        var obits = 0
                        var foo = [[Routine]]()
                        len.set(to: try tbl.get(at: Globals.pMatchlen))
                        obits.set(to: Globals.pSlocbits)
                        if _ = rmg.set(to: Globals.here.globals) {
                            rmgl.set(to: rmg.propertySize.subtract(1))
                            while true {
                                if isThisIt(
                                    obj: obj.set(to: try rmg.get(at: cnt)),
                                    tbl: tbl
                                ) {
                                    try objFound(obj: obj, tbl: tbl)
                                }
                                if cnt.increment().isGreaterThan(rmgl) {
                                    break
                                }
                            }
                        }
                        if _ = rmg.set(to: Globals.here.things) {
                            rmgl.set(to: rmg.propertySize.divide(4).subtract(1))
                            cnt.set(to: 0)
                            while true {
                                if Globals.pNam.equals(try rmg.get(at: cnt.multiply(2))) {
                                    Objects.pseudoObject.action = try rmg.get(at: cnt.multiply(2).add(1))
                                    foo.set(to: Objects.pseudoObject.action.back(bytes: 5))
                                    try foo.put(
                                        element: try Globals.pNam.get(at: 0),
                                        at: 0
                                    )
                                    try foo.put(
                                        element: try Globals.pNam.get(at: 1),
                                        at: 1
                                    )
                                    try objFound(obj: Objects.pseudoObject, tbl: tbl)
                                    break
                                } else if cnt.increment().isGreaterThan(rmgl) {
                                    break
                                }
                            }
                        }
                        if try tbl.get(at: Globals.pMatchlen).equals(len) {
                            Globals.pSlocbits.set(to: -1)
                            Globals.pTable.set(to: tbl)
                            try doSl(
                                obj: Objects.globalObjects,
                                bit1: 1,
                                bit2: 1
                            )
                            Globals.pSlocbits.set(to: obits)
                            if .and(
                                try tbl.get(at: Globals.pMatchlen).isZero,
                                Globals.parsedVerb.equals(Verb.lookInside, Verb.search, Verb.examine)
                            ) {
                                try doSl(obj: Objects.rooms, bit1: 1, bit2: 1)
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
