//
//  ValueTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ValueTests: QuelboTests {
    let factory = Factories.Value.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("VALUE"))
    }

    func testValue() throws {
        let symbol = try factory.init([
            .decimal(10)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "value",
            code: "value: 10",
            type: .int,
            children: [
                Symbol("10", type: .int, literal: true)
            ]
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
                .decimal(10),
                .decimal(9),
            ]).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("10")
            ]).process()
        )
    }
}
