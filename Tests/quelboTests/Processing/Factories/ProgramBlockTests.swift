//
//  ProgramBlockTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import Fizmo
import XCTest
@testable import quelbo

final class ProgramBlockTests: QuelboTests {
    let factory = Factories.ProgramBlock.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "isFunnyReturn", type: .bool, category: .globals),
        ])
    }

    func testFindFactory() {
        AssertSameFactory(factory, Game.findFactory("PROG", type: .zCode))
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1bkyn9b
    func testProgRoutine1() {
        let symbol = process("""
            ;"Block have own set of atoms"
            <ROUTINE TEST-PROG-1 ("AUX" X)
                <SET X 2>
                <TELL "START: ">
                <PROG (X)
                    <SET X 1>
                    <TELL N .X " "> ;"Inner X"
                >
                <TELL N .X> ;"Outer X"
                <TELL " END" CR CR>
            >
            ;"--> START: 1 2 END"
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "testProg1",
            code: """
                /// The `testProg1` (TEST-PROG-1) routine.
                func testProg1() {
                    var x = 0
                    x.set(to: 2)
                    output("START: ")
                    do {
                        var x = x
                        x.set(to: 1)
                        output(x)
                        output(" ")
                        // "Inner X"
                    }
                    output(x)
                    // "Outer X"
                    output(" END")
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))
    }

    func testProgRoutine1Evaluation() {
        /// The `testProg1` (TEST-PROG-1) routine.
        func testProg1() {
            var x: Int = 0
            x.set(to: 2)
            output("START: ")
            do {
                var x: Int = x
                x.set(to: 1)
                output(x)
                output(" ")
                // "Inner X"
            }
            output(x)
            // "Outer X"
            output(" END")
        }

        testProg1()

        XCTAssertNoDifference(outputFlush(), "START: 1 2 END")
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1bkyn9b
    func testProgRoutine2() {
        let symbol = process("""
            ;"AGAIN, Bare RETURN without ACTIVATION"
            <ROUTINE TEST-PROG-2 ()
            <TELL "START: ">
            <PROG (X) ;"X is not reinitialized between iterations. Default ACTIVATION created."
                    <SET X <+ .X 1>>
                    <TELL N .X " ">
                    <COND (<=? .X 3> <RETURN>)> ;"Bare RETURN without ACTIVATION will exit BLOCK"
                    <AGAIN> ;"AGAIN without ACTIVATION will redo BLOCK"
                >
                <TELL "RETURN EXIT BLOCK" CR CR>
            >
            ;"--> START: 1 2 3 RETURN EXIT BLOCK"
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "testProg2",
            code: """
                /// The `testProg2` (TEST-PROG-2) routine.
                func testProg2() {
                    output("START: ")
                    var x = 0
                    while true {
                        // "X is not reinitialized between iterations. Default ACTIVATION created."
                        x.set(to: x.add(1))
                        output(x)
                        output(" ")
                        if x.equals(3) {
                            break
                        }
                        // "Bare RETURN without ACTIVATION will exit BLOCK"
                        continue
                        // "AGAIN without ACTIVATION will redo BLOCK"
                    }
                    output("RETURN EXIT BLOCK")
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))
    }

    func testProgRoutine2Evaluation() {
        /// The `testProg2` (TEST-PROG-2) routine.
        func testProg2() {
            output("START: ")
            var x: Int = 0
            while true {
                // "X is not reinitialized between iterations. Default ACTIVATION created."
                x.set(to: x.add(1))
                output(x)
                output(" ")
                if x.equals(3) {
                    break
                }
                // "Bare RETURN without ACTIVATION will exit BLOCK"
                continue
                // "AGAIN without ACTIVATION will redo BLOCK"
            }
            output("RETURN EXIT BLOCK")
        }

        testProg2()

        XCTAssertNoDifference(outputFlush(), "START: 1 2 3 RETURN EXIT BLOCK")
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1bkyn9b
    func testProgRoutine3() {
        localVariables.append(
            Statement(id: "x", type: .int)
        )

        let symbol = process("""
            ;"AGAIN, RETURN with value but without ACTIVATION"
            <ROUTINE TEST-PROG-3 ()
                <TELL "START: ">
                <PROG ((X 0)) ;"X is not reinitialized between iterations. Default ACTIVATION created."
                    <SET X <+ .X 1>>
                    <TELL N .X " ">
                    <COND (<=? .X 3>
                        <COND (,FUNNY-RETURN?
                        <TELL "RETURN EXIT ROUTINE" CR CR>)>
                        <RETURN T>)> ;"RETURN with value but without ACTIVATION will exit ROUTINE (FUNNY-RETURN = TRUE)"
                    <AGAIN> ;"AGAIN without ACTIVATION will redo BLOCK"
                >
                <TELL "RETURN EXIT BLOCK" CR CR>
            >
            ;"--> START: 1 2 3 RETURN EXIT ROUTINE"
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "testProg3",
            code: """
                @discardableResult
                /// The `testProg3` (TEST-PROG-3) routine.
                func testProg3() -> Bool {
                    output("START: ")
                    var x = 0
                    while true {
                        // "X is not reinitialized between iterations. Default ACTIVATION created."
                        x.set(to: x.add(1))
                        output(x)
                        output(" ")
                        if x.equals(3) {
                            if Globals.isFunnyReturn {
                                output("RETURN EXIT ROUTINE")
                            }
                            return true
                        }
                        // "RETURN with value but without ACTIVATION will exit ROUTINE (FUNNY-RETURN = TRUE)"
                        continue
                        // "AGAIN without ACTIVATION will redo BLOCK"
                    }
                    output("RETURN EXIT BLOCK")
                }
                """,
            type: .booleanTrue,
            category: .routines,
            isCommittable: true,
            returnHandling: .passthrough
        ))
    }

    func testProgRoutine3Evaluation() {
        let isFunnyReturn = true

        @discardableResult
        /// The `testProg3` (TEST-PROG-3) routine.
        func testProg3() -> Bool {
            output("START: ")
            var x: Int = 0
            while true {
                // "X is not reinitialized between iterations. Default ACTIVATION created."
                x.set(to: x.add(1))
                output(x)
                output(" ")
                if x.equals(3) {
                    if isFunnyReturn {
                        output("RETURN EXIT ROUTINE")
                    }
                    return true
                }
                // "RETURN with value but without ACTIVATION will exit ROUTINE (FUNNY-RETURN = TRUE)"
                continue
                // "AGAIN without ACTIVATION will redo BLOCK"
            }
            // output("RETURN EXIT BLOCK") [Will never be executed]
        }

        testProg3()

        XCTAssertNoDifference(outputFlush(), "START: 1 2 3 RETURN EXIT ROUTINE")
    }
}
