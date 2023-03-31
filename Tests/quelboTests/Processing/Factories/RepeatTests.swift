//
//  RepeatTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import Fizmo
import XCTest
@testable import quelbo

final class RepeatTests: QuelboTests {
    let factory = Factories.Repeat.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "isFunnyReturn", type: .bool, category: .globals),
        ])
    }

    func testFindFactory() {
        AssertSameFactory(factory, Game.findFactory("REPEAT"))
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.hkkpf6
    func testRepeatFirstZilfExample() {
        let symbol = process("""
            ;"Bare RETURN without ACTIVATION"
            <ROUTINE TEST-REPEAT-1 ()
            <TELL "START: ">
            <REPEAT (X) ;"X is not reinitialized between iterations. Default ACTIVATION created."
                    <SET X <+ .X 1>>
                    <TELL N .X " ">
                    <COND (<=? .X 3> <RETURN>)> ;"Bare RETURN without ACTIVATION will exit BLOCK"
                >
                <TELL "RETURN EXIT BLOCK" CR CR>
            >
            ;"--> START: 1 2 3 RETURN EXIT BLOCK"
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "testRepeat1",
            code: """
                /// The `testRepeat1` (TEST-REPEAT-1) routine.
                func testRepeat1() {
                    output("START: ")
                    var x = 0
                    while true {
                        // "X is not reinitialized between iterations. Default ACTIVATION created."
                        x.set(to: .add(x, 1))
                        output(x)
                        output(" ")
                        if x.equals(3) {
                            break
                        }
                        // "Bare RETURN without ACTIVATION will exit BLOCK"
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

    func testRepeatFirstZilfEvaluation() {
        /// The `testRepeat1` (TEST-REPEAT-1) routine.
        func testRepeat1() {
            output("START: ")
            var x: Int = 0
            while true {
                // X is not reinitialized between iterations. Default ACTIVATION created.
                x.set(to: .add(x, 1))
                output(x)
                output(" ")
                if x.equals(3) {
                    break
                }
                // Bare RETURN without ACTIVATION will exit BLOCK
            }
            output("RETURN EXIT BLOCK")
        }

        testRepeat1()

        XCTAssertNoDifference(outputFlush(), "START: 1 2 3 RETURN EXIT BLOCK")
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.hkkpf6
    func testRepeatSecondZilfExample() {
        let symbol = process("""
            ;"RETURN with value but without ACTIVATION"
            <ROUTINE TEST-REPEAT-2 ()
                <TELL "START: ">
                <REPEAT ((X 0)) ;"X is not reinitialized between iterations. Default ACTIVATION created."
                    <SET X <+ .X 1>>
                    <TELL N .X " ">
                    <COND (<=? .X 3>
                        <COND (,FUNNY-RETURN?
                        <TELL "RETURN EXIT ROUTINE" CR CR>)>
                        <RETURN T>)> ;"RETURN with value but without ACTIVATION will exit ROUTINE (FUNNY-RETURN = TRUE)"
                >
                <TELL "RETURN EXIT BLOCK" CR CR>
            >
            ;"--> START: 1 2 3 RETURN EXIT ROUTINE"
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "testRepeat2",
            code: """
                @discardableResult
                /// The `testRepeat2` (TEST-REPEAT-2) routine.
                func testRepeat2() -> Bool {
                    output("START: ")
                    var x = 0
                    while true {
                        // "X is not reinitialized between iterations. Default ACTIVATION created."
                        x.set(to: .add(x, 1))
                        output(x)
                        output(" ")
                        if x.equals(3) {
                            if Globals.isFunnyReturn {
                                output("RETURN EXIT ROUTINE")
                            }
                            return true
                        }
                        // "RETURN with value but without ACTIVATION will exit ROUTINE (FUNNY-RETURN = TRUE)"
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

    func testRepeatSecondZilfEvaluation() {
        let isFunnyReturn = true

        @discardableResult
        /// The `testRepeat2` (TEST-REPEAT-2) routine.
        func testRepeat2() -> Bool {
            output("START: ")
            var x: Int = 0
            while true {
                // "X is not reinitialized between iterations. Default ACTIVATION created."
                x.set(to: .add(x, 1))
                output(x)
                output(" ")
                if x.equals(3) {
                    if isFunnyReturn {
                        output("RETURN EXIT ROUTINE")
                    }
                    return true
                }
                // "RETURN with value but without ACTIVATION will exit ROUTINE (FUNNY-RETURN = TRUE)"
            }
            // output("RETURN EXIT BLOCK") [Will never be executed]
        }

        testRepeat2()

        XCTAssertNoDifference(outputFlush(), "START: 1 2 3 RETURN EXIT ROUTINE")
    }

}
