//
//  PickOneTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/23/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PickOneTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()

        process(#"""
            <GLOBAL HELLOS
                <LTABLE 0 "Hello."
                       "Good day."
                       "Nice weather we've been having lately."
                       "Goodbye.">>

            <ROUTINE PICK-ONE (FROB
                    "AUX" (L <GET .FROB 0>) (CNT <GET .FROB 1>) RND MSG RFROB)
                <SET L <- .L 1>>
                <SET FROB <REST .FROB 2>>
                <SET RFROB <REST .FROB <* .CNT 2>>>
                <SET RND <RANDOM <- .L .CNT>>>
                <SET MSG <GET .RFROB .RND>>
                <PUT .RFROB .RND <GET .RFROB 1>>
                <PUT .RFROB 1 .MSG>
                <SET CNT <+ .CNT 1>>
                <COND (<==? .CNT .L> <SET CNT 0>)>
                <PUT .FROB 0 .CNT>
                .MSG>

            <ROUTINE V-HELLO ()
                 <COND (,PRSO
                    <COND (<FSET? ,PRSO ,ACTORBIT>
                           <TELL
            "The " D ,PRSO " bows his head to you in greeting." CR>)
                          (T
                           <TELL
            "It's a well known fact that only schizophrenics say \"Hello\" to a "
            D ,PRSO "." CR>)>)
                       (T
                    <TELL <PICK-ONE ,HELLOS> CR>)>>
        """#)
    }

    func testHellos() throws {
        XCTAssertNoDifference(
            Game.globals.find("hellos"),
            Statement(
                id: "hellos",
                code: """
                    /// The `hellos` (HELLOS) 􀎠􀁮Table global.
                    var hellos = Table(
                        "Hello.",
                        "Good day.",
                        "Nice weather we've been having lately.",
                        "Goodbye.",
                        flags: .length
                    )
                    """,
                type: .table.root,
                category: .globals,
                isCommittable: true,
                isMutable: true
            )
        )
    }

    func testPickOne() throws {
        XCTAssertNoDifference(
            Game.routines.find("pickOne"),
            Statement(
                id: "pickOne",
                code: """
                    @discardableResult
                    /// The `pickOne` (PICK-ONE) routine.
                    func pickOne(frob: Table) throws -> String {
                        var l = try frob.get(at: 0)
                        var cnt = try frob.get(at: 1)
                        var rnd = 0
                        var msg = ""
                        var rfrob: Table?
                        var frob = frob
                        l.set(to: l.subtract(1))
                        frob.set(to: frob.rest(bytes: 2))
                        rfrob.set(to: frob.rest(bytes: cnt.multiply(2)))
                        rnd.set(to: .random(l.subtract(cnt)))
                        msg.set(to: try rfrob.get(at: rnd))
                        try rfrob.put(
                            element: try rfrob.get(at: 1),
                            at: rnd
                        )
                        try rfrob.put(
                            element: msg,
                            at: 1
                        )
                        cnt.set(to: cnt.add(1))
                        if cnt.equals(l) {
                            cnt.set(to: 0)
                        }
                        try frob.put(
                            element: cnt,
                            at: 0
                        )
                        return msg
                    }
                    """,
                type: .string.tableElement,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }

    func testVHello() throws {
        XCTAssertNoDifference(
            Game.routines.find("vHello"),
            Statement(
                id: "vHello",
                code: #"""
                    /// The `vHello` (V-HELLO) routine.
                    func vHello() throws {
                        if let Globals.parsedDirectObject {
                            if Globals.parsedDirectObject?.hasFlag(.isActor) {
                                output("The ")
                                output(Globals.parsedDirectObject?.description)
                                output(" bows his head to you in greeting.")
                            } else {
                                output("""
                                    It's a well known fact that only schizophrenics say "Hello" \
                                    to a
                                    """)
                                output(Globals.parsedDirectObject?.description)
                                output(".")
                            }
                        } else {
                            output(try pickOne(frob: Globals.hellos))
                        }
                    }
                    """#,
                type: .void,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }
}
