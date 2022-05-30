//
//  DescriptionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DescriptionTests: QuelboTests {
    let factory = Factories.Description.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("DESC"))
    }

    func testDescription() throws {
        let symbol = try factory.init([
            .string("bat")
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "description",
            code: "description: \"bat\"",
            type: .string,
            children: [
                Symbol("\"bat\"", type: .string, meta: [.isLiteral])
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
                .string("Bat"),
                .string("Mouse"),
            ], with: types).process()
        )
    }
}
