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
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("TEXT"))
    }

    func testText() throws {
        let symbol = try factory.init([
            .string("The engravings translate to \"This space intentionally left blank.\"")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "text",
            code: #"""
                text: """
                    The engravings translate to "This space intentionally left \
                    blank."
                    """
                """#,
            type: .string,
            children: [
                Symbol(
                    #"""
                        """
                            The engravings translate to "This space intentionally left \
                            blank."
                            """
                        """#,
                    type: .string,
                    literal: true
                )
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
                .string("Bat"),
                .string("Mouse"),
            ]).process()
        )
    }
}
