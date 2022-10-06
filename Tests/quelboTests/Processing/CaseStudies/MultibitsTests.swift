//
//  MultibitsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/5/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class MultibitsTests: QuelboTests {
    override func setUp() {
        super.setUp()

        process("""
            <DEFINE MULTIBITS (X OBJ ATMS "AUX" (O ()) ATM)
                <REPEAT ()
                    <COND (<EMPTY? .ATMS>
                           <RETURN!- <COND (<LENGTH? .O 1> <NTH .O 1>)
                                   (<==? .X FSET?> <FORM OR !.O>)
                                   (ELSE <FORM PROG () !.O>)>>)>
                    <SET ATM <NTH .ATMS 1>>
                    <SET ATMS <REST .ATMS>>
                    <SET O
                         (<FORM .X
                            .OBJ
                            <COND (<TYPE? .ATM FORM> .ATM)
                              (ELSE <FORM GVAL .ATM>)>>
                          !.O)>>>

            <DEFMAC BSET ('OBJ "ARGS" BITS)
                <MULTIBITS FSET .OBJ .BITS>>
        """)
    }

    func testBsetMacro() throws {
        XCTAssertNoDifference(
            Game.routines.find("bset"),
            Statement(
                id: "bset",
                code: """
                    /// The `bset` (BSET) macro.
                    func bset(
                        obj: Object,
                        bits: Table
                    ) {
                        var bits: Table = bits
                        {
                            var o: [<Unknown>] = []
                            var atm: <Unknown> = <Unknown>
                            while true {
                                if bits.isEmpty {
                                    if o.count == 1 {
                                        return o.nthElement(1)
                                    } else if fset.equals(isFset) {
                                        .or(o)
                                    } else {
                                        do {
                                            return o
                                        }
                                    }
                                }
                                atm.set(to: bits.nthElement(1))
                                bits.set(to: bits.rest())
                                o.set(to: [
                                    obj.if atm.isType(form) {
                                        return atm
                                    } else {
                                        return atm
                                    }.set(true),
                                    o,
                                ])
                            }
                        }()
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true
            )
        )
    }

    func testBsetMacroCall() {
        XCTAssertNoDifference(
            process("<BSET SOME-OBJECT SOME-TABLE>"),
            .statement(
                code: """
                    bset(
                        obj: someObject,
                        bits: someTable
                    )
                    """,
                type: .void
            )
        )
    }
}
