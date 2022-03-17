//
//  Zil+EmulationTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/14/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ZilEmulationTests: XCTestCase {
    func testTable() {
        // TODO: add tests
    }

    func testSet() {
        var n = 43
        XCTAssertEqual(
            ZIL.set(&n, to: n - 1),
            42
        )

        XCTAssertFalse(
            ZIL.set(&n, to: n - 1) < 1
        )

        n = 0
        XCTAssertTrue(
            ZIL.set(&n, to: n - 1) < 1
        )
    }
}
