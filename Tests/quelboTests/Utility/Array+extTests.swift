//
//  Array+extTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/9/22.
//

import Foundation

import CustomDump
import XCTest
@testable import quelbo

final class ArrayExtTests: XCTestCase {
    func testShiftEmptyArray() {
        var array: [Int] = []
        XCTAssertNil(array.shift())
        XCTAssertEqual(array, [])
    }

    func testShiftArrayOneElement() {
        var array = ["one"]
        XCTAssertEqual(array.shift(), "one")
        XCTAssertEqual(array, [])
    }

    func testShiftArrayMultipleElements() {
        var array = [42, 43, 44]
        XCTAssertEqual(array.shift(), 42)
        XCTAssertEqual(array, [43, 44])
    }

    func testShiftAtom() {
        var array: [Token] = []
        XCTAssertNil(array.shiftAtom())
        XCTAssertEqual(array, [])
    }

    func testShiftAtomOneAtom() {
        var array: [Token] = [.atom("FOO")]
        XCTAssertEqual(array.shiftAtom(), .atom("FOO"))
        XCTAssertEqual(array, [])
    }

    func testShiftAtomOneNonAtom() {
        var array: [Token] = [.string("BAR")]
        XCTAssertNil(array.shiftAtom())
        XCTAssertEqual(array, [.string("BAR")])
    }

    func testShiftAtomMultipleTokens() {
        var array: [Token] = [
            .atom("FOO"),
            .string("BAR"),
        ]
        XCTAssertEqual(array.shiftAtom(), .atom("FOO"))
        XCTAssertEqual(array, [.string("BAR")])
    }

    func testShiftAtomMultipleTokensNonAtomFirst() {
        var array: [Token] = [
            .string("BAR"),
            .atom("FOO"),
        ]
        XCTAssertNil(array.shiftAtom())
        XCTAssertEqual(array, [
            .string("BAR"),
            .atom("FOO"),
        ])
    }
}
