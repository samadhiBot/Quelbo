//
//  ZilBooleanTests.swift
//  Fizmo
//
//  Created by Chris Sessions on 4/21/22.
//

import CustomDump
import XCTest
import Fizmo

final class ZilBooleanTests: XCTestCase {
    func testAnd() {
        XCTAssertTrue(.and(true))
        XCTAssertTrue(.and(true, true, true))
        XCTAssertFalse(.and(true, false))
    }

    func testOr() {
        XCTAssertTrue(.or(true))
        XCTAssertTrue(.or(true, true, true))
        XCTAssertTrue(.or(true, false))
        XCTAssertFalse(.or(false, false))
    }
}
