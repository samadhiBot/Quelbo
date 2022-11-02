//
//  BindTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/25/22.
//

import CustomDump
import Fizmo
import XCTest
@testable import quelbo

final class BindTests: QuelboTests {
    let factory = Factories.Bind.self
    let routineFactory = Factories.Routine.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(
                id: "isFunnyReturn",
                type: .bool,
                category: .globals
            ),
        ])
    }

    func testFindFactory() {
        AssertSameFactory(factory, Game.findFactory("BIND"))
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.12jfdx2
    func testBindRoutine1() {
        let symbol = process("""
            <ROUTINE TEST-BIND-1 ("AUX" X)
                <TELL "START ">
                <SET X 1>
                <BIND (X)
                    <SET X 2>
                    <TELL N .X " "> ;"--> 2 (Inner X)"
                >
                <TELL N .X " "> ;"--> 1 (Outer X)"
                <TELL "END" CR>
            >
            ;"--> START 2 1 END"
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "testBind1",
            code: """
                /// The `testBind1` (TEST-BIND-1) routine.
                func testBind1() {
                    var x: Int = 0
                    output("START ")
                    x.set(to: 1)
                    do {
                        var x: Int = x
                        x.set(to: 2)
                        output(x)
                        output(" ")
                        // --> 2 (Inner X)
                    }
                    output(x)
                    output(" ")
                    // --> 1 (Outer X)
                    output("END")
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true
        ))
    }
    func testBindRoutine1Evaluation() {
        /// The `testBind1` (TEST-BIND-1) routine.
        func testBind1() {
            var x: Int = 0
            output("START ")
            x.set(to: 1)
            do {
                var x: Int = x
                x.set(to: 2)
                output(x)
                output(" ")
                // --> 2 (Inner X)
            }
            output(x)
            output(" ")
            // --> 1 (Outer X)
            output("END")
        }

        testBind1()

        XCTAssertNoDifference(outputFlush(), "START 2 1 END")
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.12jfdx2
    func testBindRoutine2() {
        let symbol = process("""
            <ROUTINE TEST-BIND-2 ()
                <TELL "START ">
                <BIND (X)
                    <SET X <+ .X 1>>
                    <TELL N .X " ">
                    <COND (<=? .X 3> <RETURN>)> ;"--> exit routine"
                    <AGAIN> ;"--> top of routine"
                >
                <TELL "END" CR> ;"Never reached"
            >
            ;"--> START 1 START 2 START 3 "
        """)

        XCTAssertNoDifference(symbol, .statement(
            id: "testBind2",
            code: """
                /// The `testBind2` (TEST-BIND-2) routine.
                func testBind2() {
                    var x: Int = 0
                    while true {
                        output("START ")
                        do {
                            x.set(to: .add(x, 1))
                            output(x)
                            output(" ")
                            if x.equals(3) {
                                break
                            }
                            // --> exit routine
                            continue
                            // --> top of routine
                        }
                        output("END")
                        // Never reached
                    }
                }
                """,
            type: .void,
            category: .routines,
            isCommittable: true
        ))
    }

    func testBindRoutine2Evaluation() {
        /// The `testBind2` (TEST-BIND-2) routine.
        func testBind2() {
            var x: Int = 0
            while true {
                output("START ")
                do {
                    x.set(to: .add(x, 1))
                    output(x)
                    output(" ")
                    if x.equals(3) {
                        break
                    }
                    // --> exit routine
                    continue
                    // --> top of routine
                }
                // output("END") [Will never be executed]
                // Never reached
            }
        }

        testBind2()

        XCTAssertNoDifference(outputFlush(), "START 1 START 2 START 3 ")
    }
}
