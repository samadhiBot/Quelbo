//
//  IsVerbTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/2/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsVerbTests: QuelboTests {
    let factory = Factories.IsVerb.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("VERB?"))
    }

    func testIsVerbSingle() throws {
        let symbol = process("<VERB? EXAMINE>")

        XCTAssertNoDifference(symbol, .statement(
            code: "isVerb(.examine)",
            type: .bool
        ))
    }

    func testIsVerbMultiple() throws {
        let symbol = process("<VERB? PUT PUT-ON>")

        XCTAssertNoDifference(symbol, .statement(
            code: "isVerb(.put, .putOn)",
            type: .bool
        ))
    }

    func testIsVerbMultilineOutput() throws {
        let symbol = process("<VERB? CLIMB-UP CLIMB-DOWN CLIMB-FOO>")

        XCTAssertNoDifference(symbol, .statement(
            code: """
                isVerb(
                    .climbUp,
                    .climbDown,
                    .climbFoo
                )
                """,
            type: .bool
        ))
    }

    func testThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2")
            ], with: &localVariables).process()
        )
    }
}
