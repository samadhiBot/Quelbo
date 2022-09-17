//
//  JoinedStringsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class JoinedStringsTests: QuelboTests {
    let factory = Factories.JoinedStrings.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("STRING"))
    }

    func testJoinedStrings() throws {
        let symbol = try factory.init([
            .character("A"),
            .form([
                .atom("ASCII"),
                .decimal(66)
            ]),
            .string("CD")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: """
            ["A", 66.ascii, "CD"].joined()
            """,
            type: .string
        ))
    }
}
