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
        AssertSameFactory(factory, Game.findPropertyFactory("STRENGTH"))
    }

    func testStrength() throws {
        let symbol = try factory.init([
            .decimal(2)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "strength",
            code: "strength: 2",
            type: .int,
            confidence: .certain
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "strength",
            type: .int,
            confidence: .certain
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(2),
                .decimal(3),
            ], with: &localVariables).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2")
            ], with: &localVariables).process()
        )
    }
}
