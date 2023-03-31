//
//  IsTypeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/30/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsTypeTests: QuelboTests {
    let factory = Factories.IsType.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("TYPE?"))
    }

    func testIsTypeFix() throws {
        let symbol = process("<TYPE? .DEST FIX>", with: [
            Statement(id: "dest", code: "var dest = 1", type: .int)
        ])

        XCTAssertNoDifference(symbol, .statement(
            code: """
                dest.isType(.fix)
                """,
            type: .bool
        ))
    }
}
