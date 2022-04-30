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
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("LDESC"))
    }

    func testLongDescription() throws {
        let symbol = try factory.init([
            .string("""
                Lying in one corner of the room is a beautifully carved crystal skull. \
                It appears to be grinning at you rather nastily.
                """)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "longDescription",
            code: #"""
                longDescription: """
                    Lying in one corner of the room is a beautifully carved \
                    crystal skull. It appears to be grinning at you rather \
                    nastily.
                    """
                """#,
            type: .string,
            children: [
                Symbol(
                    #"""
                        """
                            Lying in one corner of the room is a beautifully carved \
                            crystal skull. It appears to be grinning at you rather \
                            nastily.
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
