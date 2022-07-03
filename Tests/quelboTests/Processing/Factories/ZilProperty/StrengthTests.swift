//
//  StrengthTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class StrengthTests: QuelboTests {
    let factory = Factories.Strength.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("STRENGTH"))
    }

    func testStrength() throws {
        let symbol = try factory.init([
            .decimal(2)
        ], with: &registry).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "strength",
            code: "strength: 2",
            type: .int
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ], with: &registry).process()
        )
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ], with: &registry).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2")
            ], with: &registry).process()
        )
    }
}
