//
//  ZilComparableTests.swift
//  Fizmo
//
//  Created by Chris Sessions on 4/21/22.
//

import CustomDump
import XCTest
import Fizmo

final class ZilComparableTests: XCTestCase {

    // MARK: - Equals

    func testEqualsInt() {
        XCTAssertTrue(1.equals(1))
        XCTAssertTrue(2.equals(2, 2))
        XCTAssertTrue(3.equals(3, 3, 3))

        XCTAssertFalse(1.equals(2))
        XCTAssertFalse(2.equals(2, 3))
        XCTAssertFalse(3.equals(3, 3, 4))

        let six: Int = 6
        XCTAssertTrue((1 + 5).equals(six))
        XCTAssertTrue(six.equals(1 + 5, 6))
    }

    func testEqualsString() {
        XCTAssertTrue("hello".equals("hello"))
        XCTAssertTrue("bye".equals("bye", "bye"))

        XCTAssertFalse("hello".equals("goodbye"))
        XCTAssertFalse("hello".equals("hello", "goodbye"))

        let hello: String = "hello"
        XCTAssertTrue(hello.equals("hello"))
        XCTAssertTrue(hello.equals("he" + "llo"))
    }

    // MARK: - IsGreaterThan

    func testIsGreaterThanInt() {
        XCTAssertTrue(9.isGreaterThan(8))

        XCTAssertFalse(9.isGreaterThan(9))
        XCTAssertFalse(9.isGreaterThan(10))
        XCTAssertFalse(9.isGreaterThan(7, 8, 9))

        let five: Int = 5
        XCTAssertTrue(five.isGreaterThan(4))
        XCTAssertTrue(five.isGreaterThan(2, 3, 4))
        XCTAssertFalse(five.isGreaterThan(five, 6))
    }

    func testIsGreaterThanString() {
        XCTAssertTrue("b".isGreaterThan("a"))
        XCTAssertFalse("a".isGreaterThan("b"))

        let eff: String = "f"
        XCTAssertTrue(eff.isGreaterThan("e"))
        XCTAssertFalse("e".isGreaterThan(eff))
    }

    // MARK: - IsGreaterThanOrEqualTo

    func testIsGreaterThanOrEqualToInt() {
        XCTAssertTrue(9.isGreaterThanOrEqualTo(8))
        XCTAssertTrue(9.isGreaterThanOrEqualTo(9))
        XCTAssertTrue(9.isGreaterThanOrEqualTo(7, 8, 9))

        XCTAssertFalse(9.isGreaterThanOrEqualTo(10))

        let five: Int = 5
        XCTAssertTrue(five.isGreaterThanOrEqualTo(4))
        XCTAssertTrue(five.isGreaterThanOrEqualTo(3, 4, 5))
        XCTAssertFalse(five.isGreaterThanOrEqualTo(five, 6))
    }

    func testIsGreaterThanOrEqualToString() {
        XCTAssertTrue("b".isGreaterThanOrEqualTo("a"))
        XCTAssertFalse("a".isGreaterThanOrEqualTo("b"))

        let eff: String = "f"
        XCTAssertTrue(eff.isGreaterThanOrEqualTo("e"))
        XCTAssertFalse("e".isGreaterThanOrEqualTo(eff))
    }

    // MARK: - IsLessThan

    func testIsLessThanInt() {
        XCTAssertTrue(9.isLessThan(10))

        XCTAssertFalse(9.isLessThan(9))
        XCTAssertFalse(9.isLessThan(8))
        XCTAssertFalse(9.isLessThan(8, 9, 10))

        let five: Int = 5
        XCTAssertTrue(five.isLessThan(6))
        XCTAssertTrue(five.isLessThan(6, 60, 600))
        XCTAssertFalse(five.isLessThan(five, 6))
    }

    func testIsLessThanString() {
        XCTAssertTrue("a".isLessThan("b"))

        XCTAssertFalse("a".isLessThan("a"))
        XCTAssertFalse("b".isLessThan("a"))

        let eff: String = "f"
        XCTAssertTrue(eff.isLessThan("g"))
        XCTAssertFalse("z".isLessThan(eff))
    }

    // MARK: - IsLessThanOrEqualTo

    func testIsLessThanOrEqualToInt() {
        XCTAssertTrue(9.isLessThanOrEqualTo(10))
        XCTAssertTrue(9.isLessThanOrEqualTo(9, 10))

        XCTAssertFalse(9.isLessThanOrEqualTo(8))
        XCTAssertFalse(9.isLessThanOrEqualTo(8, 9, 10))

        let five: Int = 5
        XCTAssertTrue(five.isLessThanOrEqualTo(6))
        XCTAssertTrue(five.isLessThanOrEqualTo(5, 50, 500))
        XCTAssertFalse(five.isLessThanOrEqualTo(five, 4))
    }

    func testIsLessThanOrEqualToString() {
        XCTAssertTrue("a".isLessThanOrEqualTo("b"))
        XCTAssertTrue("a".isLessThanOrEqualTo("a", "b"))

        XCTAssertFalse("c".isLessThanOrEqualTo("a", "b"))

        let eff: String = "f"
        XCTAssertTrue(eff.isLessThanOrEqualTo("f", "g"))
        XCTAssertFalse("z".isLessThanOrEqualTo(eff))
    }

    // MARK: - IsNotEqualTo

    func testIsNotEqualToInt() {
        XCTAssertTrue(1.isNotEqualTo(2))
        XCTAssertTrue(2.isNotEqualTo(3, 4))
        XCTAssertTrue(3.isNotEqualTo(4, 5, 6))

        XCTAssertFalse(1.isNotEqualTo(1))
        XCTAssertFalse(2.isNotEqualTo(2, 3))
        XCTAssertFalse(3.isNotEqualTo(3, 4, 5))

        let six: Int = 6
        XCTAssertTrue((2 + 5).isNotEqualTo(six))
        XCTAssertFalse((1 + 5).isNotEqualTo(six))
        XCTAssertTrue(six.isNotEqualTo(3 + 2, 3 + 4))
    }

    func testIsNotEqualToString() {
        XCTAssertTrue("hello".isNotEqualTo("goodbye"))
        XCTAssertTrue("hello".isNotEqualTo("Ciao", "goodbye"))

        XCTAssertFalse("hello".isNotEqualTo("hello"))
        XCTAssertFalse("bye".isNotEqualTo("good", "bye"))


        let hello: String = "hello"
        XCTAssertTrue(hello.isNotEqualTo("goodbye"))
        XCTAssertFalse(hello.isNotEqualTo("he" + "llo"))
    }
}
