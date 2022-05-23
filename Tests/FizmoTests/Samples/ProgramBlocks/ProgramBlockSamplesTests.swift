//
//  ProgramBlockSamplesTests.swift
//  Fizmo
//
//  Created by Chris Sessions on 4/23/22.
//

import CustomDump
import XCTest
import Fizmo

final class ProgramBlockSamplesTests: XCTestCase {
    var samples = ProgramBlockSamples()

    // MARK: - AGAIN

    func testAgain1() {
        samples.testAgain1()

        XCTAssertNoDifference(outputFlush(), "1 2 3 4 5 ")
    }

    func testAgain2() {
        // `testAgain2()` is infinitely repeating 1's
    }

    func testAgain3() {
        samples.testAgain3()

        XCTAssertNoDifference(outputFlush(), "1 2 3 4 5 ")
    }

    func testAgain4() {
        samples.testAgain4()

        XCTAssertNoDifference(outputFlush(), "1 2 3 4 5 ")
    }

    // MARK: - BIND

    func testBind1() {
        samples.testBind1()

        XCTAssertNoDifference(outputFlush(), "START 2 1 END")
    }

    func testBind2() {
        samples.testBind2()

        XCTAssertNoDifference(outputFlush(), "START 1 START 2 START 3 ")
    }

    // MARK: - DEFINE

    func testIncForm() {
        let result = samples.incForm(a: 1)

        XCTAssertEqual(result, 2)
    }

    func testMyadd() {
        let result = samples.myadd(x1: 4, x2: 5)

        XCTAssertEqual(result, 9)
    }

    func testPowerTo() {
        let result = samples.powerTo(x: 3, y: 3)

        XCTAssertEqual(result, 27)
    }

    func testSquare() {
        let result = samples.square(x: 5)

        XCTAssertEqual(result, 25)
    }

    // MARK: - PROG

    func testProg1() {
        samples.testProg1()

        XCTAssertNoDifference(outputFlush(), "START: 1 2 END")
    }

    func testProg2() {
        samples.testProg2()

        XCTAssertNoDifference(outputFlush(), "START: 1 2 3 RETURN EXIT BLOCK")
    }

    func testProg3() {
        samples.testProg3()

        XCTAssertNoDifference(outputFlush(), "START: 1 2 3 RETURN EXIT ROUTINE")
    }

    // MARK: - REPEAT

    func testRepeat1() {
        samples.testRepeat1()

        XCTAssertNoDifference(
            outputFlush(),
            "START: 1 2 3 RETURN EXIT BLOCK"
        )
    }

    func testRepeat2() {
        samples.testRepeat2()

        XCTAssertNoDifference(
            outputFlush(),
            "START: 1 2 3 RETURN EXIT ROUTINE"
        )
    }
}
