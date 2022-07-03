//
//  GlobalsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GlobalsTests: QuelboTests {
    let factory = Factories.Globals.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("GLOBAL"))
    }

    func testGlobals() throws {
        let symbol = try factory.init([
            .atom("WELL-HOUSE"),
            .atom("STREAM"),
            .atom("ROAD"),
            .atom("FOREST")
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "globals",
            code: """
                globals: [
                    wellHouse,
                    stream,
                    road,
                    forest,
                ]
                """,
            type: .array(.object)
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ], with: &registry).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("42"),
            ], with: &registry).process()
        )
    }
}
