//
//  InsertFileTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/20/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class InsertFileTests: QuelboTests {
    let factory = Factories.InsertFile.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("INSERT-FILE"))
    }

    func testString() throws {
        let symbol = process("""
            <INSERT-FILE "GMACROS" T>
        """)

        XCTAssertNoDifference(symbol, .emptyStatement)
    }
}
