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
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("FDESC"))
    }

    func testFirstDescription() throws {
        let symbol = try factory.init([
            .string("""
                Lying in one corner of the room is a beautifully carved crystal skull. \
                It appears to be grinning at you rather nastily.
                """)
        ], with: types).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "firstDescription",
            code: #"""
                firstDescription: """
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
                    meta: [.isLiteral]
                )
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
