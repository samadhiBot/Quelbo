//
//  PrintContentsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PrintContentsTests: QuelboTests {
    override func setUp() {
        super.setUp()

        process("""
            <GLOBAL P-IT-OBJECT <>>

            <ROUTINE THIS-IS-IT (OBJ)
                 <SETG P-IT-OBJECT .OBJ>>

            <ROUTINE PRINT-CONTENTS (OBJ "AUX" F N (1ST? T) (IT? <>) (TWO? <>))
                 <COND (<SET F <FIRST? .OBJ>>
                    <REPEAT ()
                        <SET N <NEXT? .F>>
                        <COND (.1ST? <SET 1ST? <>>)
                              (ELSE
                               <TELL ", ">
                               <COND (<NOT .N> <TELL "and ">)>)>
                        <TELL "a " D .F>
                        <COND (<AND <NOT .IT?> <NOT .TWO?>>
                               <SET IT? .F>)
                              (ELSE
                               <SET TWO? T>
                               <SET IT? <>>)>
                        <SET F .N>
                        <COND (<NOT .F>
                               <COND (<AND .IT? <NOT .TWO?>>
                                  <THIS-IS-IT .IT?>)>
                               <RTRUE>)>>)>>
        """, type: .mdl)
    }

    func testPItObject() {
        XCTAssertNoDifference(
            Game.findInstance("pItObject"),
            Instance(Statement(
                id: "pItObject",
                code: """
                    /// The `pItObject` (P-IT-OBJECT) 􀎠Object? global.
                    var pItObject: Object?
                    """,
                type: .object.optional,
                category: .globals,
                isCommittable: true,
                isMutable: true
            ))
        )
    }

    func testThisIsIt() {
        XCTAssertNoDifference(
            Game.routines.find("thisIsIt"),
            Statement(
                id: "thisIsIt",
                code: """
                    @discardableResult
                    /// The `thisIsIt` (THIS-IS-IT) routine.
                    func thisIsIt(obj: Object) -> Object? {
                        return Globals.pItObject?.set(to: obj)
                    }
                    """,
                type: .object.optional,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testPrintContents() {
        XCTAssertNoDifference(
            Game.routines.find("printContents"),
            Statement(
                id: "printContents",
                code: """
                    @discardableResult
                    /// The `printContents` (PRINT-CONTENTS) routine.
                    func printContents(obj: Object) -> Bool {
                        var f: Object?
                        var n: Object?
                        var is1St = true
                        var isIt: Object?
                        var isTwo = false
                        if _ = f.set(to: obj.firstChild) {
                            while true {
                                n.set(to: f.nextSibling)
                                if is1St {
                                    is1St.set(to: false)
                                } else {
                                    output(", ")
                                    if .isNot(n) {
                                        output("and ")
                                    }
                                }
                                output("a ")
                                output(f.description)
                                if .and(.isNot(isIt), .isNot(isTwo)) {
                                    isIt.set(to: f)
                                } else {
                                    isTwo.set(to: true)
                                    isIt.set(to: nil)
                                }
                                f.set(to: n)
                                if .isNot(f) {
                                    if _ = .and(.object(isIt), .isNot(isTwo)) {
                                        thisIsIt(obj: isIt)
                                    }
                                    return true
                                }
                            }
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
