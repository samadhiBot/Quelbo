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
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("TVALUE"))
    }

    func testTakeValue() throws {
        let symbol = try factory.init([
            .decimal(10)
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "takeValue",
            code: "takeValue: 10",
            type: .int,
            children: [
                Symbol("10", type: .int, meta: [.isLiteral])
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
                .decimal(10),
                .decimal(9),
            ], with: types).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("10")
            ], with: types).process()
        )
    }
}
