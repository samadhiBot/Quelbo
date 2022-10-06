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
        AssertSameFactory(factory, Game.findFactory("SIZE", type: .property))
    }

    func testSize() throws {
        let symbol = try factory.init([
            .decimal(4)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "size",
            code: "size: 4",
            type: .int
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "size",
            type: .int
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .decimal(4),
                .decimal(5),
            ], with: &localVariables).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("4")
            ], with: &localVariables).process()
        )
    }
}
