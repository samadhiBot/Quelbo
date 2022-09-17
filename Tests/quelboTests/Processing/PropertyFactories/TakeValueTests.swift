//
//  TakeValueTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class TakeValueTests: QuelboTests {
    let factory = Factories.TakeValue.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findPropertyFactory("TVALUE"))
    }

    func testTakeValue() throws {
        let symbol = try factory.init([
            .decimal(10)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "takeValue",
            code: "takeValue: 10",
            type: .int
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "takeValue",
            type: .int
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(10),
                .decimal(9),
            ], with: &localVariables).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("10")
            ], with: &localVariables).process()
        )
    }
}
