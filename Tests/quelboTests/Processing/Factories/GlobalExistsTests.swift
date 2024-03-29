//
//  GlobalExistsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/7/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class GlobalExistsTests: QuelboTests {
    let factory = Factories.GlobalExists.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("GASSIGNED?"))
    }

    func testGlobalExistsTrue() throws {
        let symbol = process("""
            <GASSIGNED? ZILCH>
        """)

        XCTAssertNoDifference(symbol, .false)
    }

    func testGlobalExistsFalse() throws {
        let symbol = process("""
            <GLOBAL ZILCH 42>

            <GASSIGNED? ZILCH>
        """)

        XCTAssertNoDifference(symbol, .true)
    }
}
