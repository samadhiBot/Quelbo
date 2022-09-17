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
        AssertSameFactory(factory, Game.findPropertyFactory("DESC"))
    }

    func testDescription() throws {
        let symbol = try factory.init([
            .string("bat")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "description",
            code: "description: \"bat\"",
            type: .string
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "description",
            type: .string
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("Bat"),
                .string("Mouse"),
            ], with: &localVariables).process()
        )
    }
}
