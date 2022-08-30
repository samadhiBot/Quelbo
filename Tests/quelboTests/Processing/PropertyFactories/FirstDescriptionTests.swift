//
//  FirstDescriptionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class FirstDescriptionTests: QuelboTests {
    let factory = Factories.FirstDescription.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findPropertyFactory("FDESC"))
    }

    func testFirstDescription() throws {
        let symbol = try factory.init([
            .string("""
                Lying in one corner of the room is a beautifully carved crystal skull. \
                It appears to be grinning at you rather nastily.
                """)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "firstDescription",
            code: #"""
                firstDescription: """
                    Lying in one corner of the room is a beautifully carved \
                    crystal skull. It appears to be grinning at you rather \
                    nastily.
                    """
                """#,
            type: .string,
            confidence: .certain
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "firstDescription",
            type: .string,
            confidence: .certain
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
