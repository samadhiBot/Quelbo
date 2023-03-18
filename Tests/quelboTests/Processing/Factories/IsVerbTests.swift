//
//  IsVerbTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/23/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsVerbTests: QuelboTests {
    let factory = Factories.IsParsedVerb.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("VERB?"))
    }

    func testIsVerbSingle() throws {
        let symbol = process("<VERB? EXAMINE>")

        XCTAssertNoDifference(symbol, .statement(
            code: "isParsedVerb(.examine)",
            type: .bool
        ))
    }

    func testIsVerbMultiple() throws {
        let symbol = process("<VERB? PUT PUT-ON>")

        XCTAssertNoDifference(symbol, .statement(
            code: "isParsedVerb(.put, .putOn)",
            type: .bool
        ))
    }

    func testIsVerbMultilineOutput() throws {
        let symbol = process("<VERB? CLIMB-UP CLIMB-DOWN CLIMB-FOO>")

        XCTAssertNoDifference(symbol, .statement(
            code: "isParsedVerb(.climbUp, .climbDown, .climbFoo)",
            type: .bool
        ))
    }
}
