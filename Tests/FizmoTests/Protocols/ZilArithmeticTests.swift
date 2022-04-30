//
//  ZilArithmetic.swift
//  Fizmo
//
//  Created by Chris Sessions on 4/21/22.
//

import CustomDump
import XCTest
import Fizmo

final class ZilArithmetic: XCTestCase {
    func testStaticAdd() {
        XCTAssertEqual(.add(2, 3, 4), 9)
    }

    func testStaticDivide() {
        XCTAssertEqual(.divide(100, 5, 2), 10)
    }

    func testStaticMultiply() {
        XCTAssertEqual(.multiply(2, 3, 4), 24)
    }

    func testStaticSubtract() {
        XCTAssertEqual(.subtract(10, 5, 4), 1)

        XCTAssertEqual(.subtract(42), -42)
    }

    func testAdd() {
        var five: Int = 5
        XCTAssertEqual(five.add(1, 2, 3, 4), 15)
    }

    func testDecrement() {
        var five: Int = 5
        XCTAssertEqual(five.decrement(), 4)
    }

    func testDivide() {
        var hundred: Int = 100
        XCTAssertEqual(hundred.divide(5, 2, 5), 2)
    }

    func testMultiply() {
        var five: Int = 5
        XCTAssertEqual(five.multiply(2, 3), 30)
    }

    func testSubtract() {
        var ten: Int = 10
        XCTAssertEqual(ten.subtract(1, 2, 3), 4)

        var fortyTwo = 42
        XCTAssertEqual(fortyTwo.subtract(), -42)
    }
}
