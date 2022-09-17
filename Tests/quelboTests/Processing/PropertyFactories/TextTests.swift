//
//  TextTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class TextTests: QuelboTests {
    let factory = Factories.Text.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findPropertyFactory("TEXT"))
    }

    func testText() throws {
        let symbol = try factory.init([
            .string("The engravings translate to \"This space intentionally left blank.\"")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "text",
            code: #"""
                text: """
                    The engravings translate to "This space intentionally left \
                    blank."
                    """
                """#,
            type: .string
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "text",
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
