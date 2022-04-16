//
//  SizeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SizeTests: QuelboTests {
    let factory = Factories.Size.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("SIZE"))
    }

    func testSize() throws {
        let symbol = try factory.init([
            .decimal(4)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "size",
            code: "size: 4",
            type: .int,
            children: [
                Symbol("4", type: .int)
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
                .decimal(4),
                .decimal(5),
            ]).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("4")
            ]).process()
        )
    }
}
