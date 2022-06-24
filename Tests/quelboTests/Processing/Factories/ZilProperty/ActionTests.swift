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
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("ACTION"))
    }

    func testAction() throws {
        let symbol = try factory.init([
            .atom("WHITE-HOUSE-F")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "action: whiteHouseFunc",
            type: .routine
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ]).process()
        )
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("WHITE-HOUSE-F"),
                .atom("RED-HOUSE-F"),
            ]).process()
        )
    }
}
