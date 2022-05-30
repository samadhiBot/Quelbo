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
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("IN"))
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("LOC"))
    }

    func testLocation() throws {
        let symbol = try factory.init([
            .atom("LOCAL-GLOBALS")
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "location",
            code: "location: localGlobals",
            type: .object,
            children: [
                Symbol("localGlobals", type: .object)
            ]
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ], with: types).process()
        )
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("WHITE-HOUSE"),
                .atom("RED-HOUSE"),
            ], with: types).process()
        )
    }
}
