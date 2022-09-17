//
//  ActionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ActionTests: QuelboTests {
    let factory = Factories.Action.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findPropertyFactory("ACTION"))
    }

    func testAction() throws {
        let symbol = try factory.init([
            .atom("WHITE-HOUSE-F")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "action",
            code: "action: whiteHouseFunc",
            type: .routine
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "action",
            type: .int
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("WHITE-HOUSE-F"),
                .atom("RED-HOUSE-F"),
            ], with: &localVariables).process()
        )
    }
}
