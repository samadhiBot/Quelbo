//
//  DefineMacroTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/2/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DefineMacroTests: QuelboTests {
    let factory = Factories.DefineMacro.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("DEFMAC"))
    }

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "contBit", type: .bool, category: .flags),
            .variable(id: "doorBit", type: .bool, category: .flags),
        ])
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.206ipza
    func testIncreaseMacro() throws {
        let inc = process("""
            <DEFMAC INC (ATM "OPTIONAL" (N 1))
                    <FORM SET .ATM
                        <FORM + <FORM LVAL .ATM> .N>>>
        """)

        XCTAssertNoDifference(inc, .statement(
            id: "inc",
            code: """
                @discardableResult
                /// The `inc` (INC) macro.
                func inc(atm: Int, n: Int = 1) -> Int {
                    var atm = atm
                    return atm.set(to: atm.add(n))
                }
                """,
            type: .int,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))

        XCTAssertNoDifference(
            process("<INC FOO>"),
            .statement(
                id: "inc",
                code: "inc(atm: foo)",
                type: .int,
                returnHandling: .implicit
            )
        )

        XCTAssertNoDifference(
            process("<INC BAR 42>"),
            .statement(
                id: "inc",
                code: "inc(atm: bar, n: 42)",
                type: .int,
                returnHandling: .implicit
            )
        )
    }

    func testIsOpenableMacro() throws {
        process("<GLOBAL PRSI <>>")

        let isOpenable = process("""
            <DEFMAC OPENABLE? ('OBJ)
                <FORM OR <FORM FSET? .OBJ ',DOORBIT>
                         <FORM FSET? .OBJ ',CONTBIT>>>
        """)

        XCTAssertNoDifference(isOpenable, .statement(
            id: "isOpenable",
            code: """
                @discardableResult
                /// The `isOpenable` (OPENABLE?) macro.
                func isOpenable(obj: Object) -> Bool {
                    return .or(
                        obj.hasFlag(.doorBit),
                        obj.hasFlag(.contBit)
                    )
                }
                """,
            type: .bool,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))

        XCTAssertNoDifference(
            process("<OPENABLE? ,PRSI>"),
            .statement(
                id: "isOpenable",
                code: "isOpenable(obj: Globals.parsedIndirectObject)",
                type: .bool,
                returnHandling: .implicit
            )
        )
    }

    // https://mdl-language.readthedocs.io/en/latest/17-macro-operations/#172-eval-macros
    func testDoubleMacro() throws {
        let double = process("""
            <DEFMAC DOUBLE ('ANY)
                    <FORM PROG ((X .ANY)) #DECL ((X) FIX) '<+ .X .X>>>
        """)

        XCTAssertNoDifference(double, .statement(
            id: "double",
            code: """
                @discardableResult
                /// The `double` (DOUBLE) macro.
                func double(any: Int) -> Int {
                    do {
                        return x.add(x)
                    }
                }
                """,
            type: .int,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))

        XCTAssertNoDifference(
            process("<DOUBLE 21>"),
            .statement(
                id: "double",
                code: "double(any: 21)",
                type: .int,
                returnHandling: .implicit
            )
        )
    }

    func testBottlesMacro() throws {
        let bottles = process(#"""
            <DEFMAC BOTTLES ('N)
                <FORM PROG '()
                    <FORM PRINTN .N>
                    <FORM PRINTI " bottle">
                    <FORM COND <LIST <FORM N==? .N 1> '<PRINTC !\s>>>>>
        """#)

        XCTAssertNoDifference(bottles, .statement(
            id: "bottles",
            code: """
                /// The `bottles` (BOTTLES) macro.
                func bottles(n: Int) {
                    do {
                        output(n)
                        output(" bottle")
                        if n.isNotEqualTo(1) {
                            output("s")
                        }
                    }
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))

        XCTAssertNoDifference(
            process("<BOTTLES 99>"),
            .statement(
                id: "bottles",
                code: "bottles(n: 99)",
                type: .void,
                returnHandling: .implicit
            )
        )
    }
}
