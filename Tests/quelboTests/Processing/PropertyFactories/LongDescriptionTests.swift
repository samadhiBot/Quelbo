//
//  LongDescriptionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class LongDescriptionTests: QuelboTests {
    let factory = Factories.LongDescription.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findPropertyFactory("LDESC"))
    }

    func testLongDescription() throws {
        let symbol = try factory.init([
            .string("""
                Lying in one corner of the room is a beautifully carved crystal skull. \
                It appears to be grinning at you rather nastily.
                """)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "longDescription",
            code: #"""
                longDescription: """
                    Lying in one corner of the room is a beautifully carved \
                    crystal skull. It appears to be grinning at you rather \
                    nastily.
                    """
                """#,
            type: .string
        ))
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "longDescription",
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
