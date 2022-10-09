//
//  IsVerbZorkTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/2/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsVerbZorkTests: QuelboTests {
    override func setUp() {
        super.setUp()

        process("""
            <GLOBAL PRSA <>>

            <DEFINE MULTIFROB (X ATMS "AUX" (OO (OR)) (O .OO) (L ()) ATM)
                <REPEAT ()
                    <COND (<EMPTY? .ATMS>
                           <RETURN!- <COND (<LENGTH? .OO 1> <ERROR .X>)
                                   (<LENGTH? .OO 2> <NTH .OO 2>)
                                   (ELSE <CHTYPE .OO FORM>)>>)>
                    <REPEAT ()
                        <COND (<EMPTY? .ATMS> <RETURN!->)>
                        <SET ATM <NTH .ATMS 1>>
                        <SET L
                             (<COND (<TYPE? .ATM ATOM>
                                 <FORM GVAL
                                   <COND (<==? .X PRSA>
                                      <PARSE
                                        <STRING "V?"
                                            <SPNAME .ATM>>>)
                                     (ELSE .ATM)>>)
                                (ELSE .ATM)>
                              !.L)>
                        <SET ATMS <REST .ATMS>>
                        <COND (<==? <LENGTH .L> 3> <RETURN!->)>>
                    <SET O <REST <PUTREST .O (<FORM EQUAL? <FORM GVAL .X> !.L>)>>>
                    <SET L ()>>>

            <DEFMAC VERB? ("ARGS" ATMS)
                <MULTIFROB PRSA .ATMS>>
        """, type: .mdl)
    }

    func testZorkMultifrob() throws {
        XCTAssertNoDifference(
            Game.routines.find("multifrob"),
            Statement(
                id: "multifrob",
                code: """
                    /// The `multifrob` (MULTIFROB) routine.
                    func multifrob(
                        prsa: Int,
                        atms: Table
                    ) {
                        var oo: [<Unknown>] = [or]
                        var o: [<Unknown>] = oo
                        var l: [<Unknown>] = []
                        var atm: <Unknown> = <Unknown>
                        var prsa: Int = prsa
                        var atms: Table = atms
                        while true {
                            if atms.isEmpty {
                                if oo.count == 1 {
                                    throw FizmoError.mdlError(prsa)
                                } else if oo.count == 2 {
                                    return oo.nthElement(2)
                                } else {
                                    oo.changeType(.form)
                                }
                            }
                            while true {
                                if atms.isEmpty {
                                    break
                                }
                                atm.set(to: atms.nthElement(1))
                                l.set(to: [
                                    if atm.isType(atom) {
                                        if prsa.equals(prsa) {
                                            [
                                                ["V?", atm.id].joined(),
                                            ].parse()
                                        } else {
                                            return atm
                                        }
                                    } else {
                                        return atm
                                    },
                                    l,
                                ])
                                atms.set(to: atms.rest())
                                if l.count.equals(3) {
                                    break
                                }
                            }
                            o.set(to: o.putRest([prsa.equals(l)]).rest())
                            l.set(to: [])
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true
            )
        )
    }

    func testZorkIsVerb() throws {
        XCTAssertNoDifference(
            Game.routines.find("isVerb"),
            Statement(
                id: "isVerb",
                code: """
                    /// The `isVerb` (VERB?) macro.
                    func isVerb(atms: Table) {
                        var atms: Table = atms
                        multifrob(
                            prsa: prsa,
                            atms: atms
                        )
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true
            )
        )
    }

    func testMethodThatCallsFizmoIsVerb() {
        let treasureInside = process("""
            <ROUTINE TREASURE-INSIDE ()
                     <COND (<VERB? OPEN>
                        <TELL "You've found an emerald!" CR>
                        <RFALSE>)>>
        """)

        XCTAssertNoDifference(treasureInside, .statement(
            id: "treasureInside",
            code: """
                @discardableResult
                /// The `treasureInside` (TREASURE-INSIDE) routine.
                func treasureInside() -> Bool {
                    if isVerb(.open) {
                        output("You've found an emerald!")
                        return false
                    }
                }
                """,
            type: .booleanFalse,
            category: .routines,
            isCommittable: true
        ))
    }
}
