//
//  NullFuncTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class NullFuncTests2: QuelboTests {
    let factory = Factories.NullFunc.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("NULL-F"))
    }

    func testNullFunc() throws {
        let symbol = process("<NULL-F>")

        XCTAssertNoDifference(symbol, .statement(
            id: "nullFunc",
            code: "nullFunc()",
            type: .bool,
            isFunctionCall: true
        ))
    }
}
