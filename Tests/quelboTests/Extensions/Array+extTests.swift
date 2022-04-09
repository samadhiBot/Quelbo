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

final class ArrayExtTests: QuelboTests {
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
}
