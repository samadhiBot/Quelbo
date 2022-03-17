//
//  RoutineCodeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/11/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RoutineCodeTests: XCTestCase {
    func testProcessAtom() {
        var code = Routine.Code([.atom("FOO")])
        XCTAssertNoDifference(
            try code.process(),
            "return foo"
        )
    }

    func testProcessAtomIndented() {
        var code = Routine.Code([.atom("BAR")], nestLevel: 1)
        XCTAssertNoDifference(
            try code.process(),
            "    return bar"
        )
    }

    func testProcessBoolTrue() {
        var code = Routine.Code([.bool(true)])
        XCTAssertNoDifference(
            try code.process(),
            "true"
        )
    }

    func testProcessBoolFalse() {
        var code = Routine.Code([.bool(false)])
        XCTAssertNoDifference(
            try code.process(),
            "false"
        )
    }

    func testProcessCommented() {
        var code = Routine.Code([.commented(.decimal(42))])
        XCTAssertNoDifference(
            try code.process(),
            "// 42"
        )
    }

    func testProcessForm() {
        var code = Routine.Code([.form([
            .atom("ROB"),
            .atom(",WINNER"),
            .atom(",THIEF")
        ])])
        XCTAssertNoDifference(
            try code.process(),
            "rob(World.winner, World.thief)"
        )
    }

    func testProcessList() {
        // TODO: add tests
    }

    func testProcessString() {
        var code = Routine.Code([.string("Bad luck, huh?")])
        XCTAssertNoDifference(
            try code.process(),
            """
            "Bad luck, huh?"
            """
        )
    }

    func testProcessMultilineString() {
        var code = Routine.Code([.string(
            """
            Your rather indelicate handling of the egg has caused it some damage,
            although you have succeeded in opening it.
            """
        )])
        XCTAssertNoDifference(
            try code.process(),
            #"""
            """
                Your rather indelicate handling of the egg has caused it some damage,
                although you have succeeded in opening it.
                """
            """#
        )
    }
}

