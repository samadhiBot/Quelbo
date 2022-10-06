//
//  LocationTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class LocationTests: QuelboTests {
    let factory = Factories.Location.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("IN", type: .property))
        AssertSameFactory(factory, Game.findFactory("LOC", type: .property))
    }

    func testLocation() throws {
        let symbol = try factory.init([
            .atom("LOCAL-GLOBALS")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "location",
            code: "location: localGlobals",
            type: .object,
            category: .rooms
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "location",
            type: .object
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("WHITE-HOUSE"),
                .atom("RED-HOUSE"),
            ], with: &localVariables).process()
        )
    }
}
