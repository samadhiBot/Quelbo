//
//  ParentTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ParentTests: QuelboTests {
    let factory = Factories.Parent.self

    override func setUp() {
        super.setUp()

        process("<OBJECT THIEF>")
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("LOC", type: .zCode))
    }

    func testThiefsLocation() throws {
        let symbol = process("<LOC THIEF>", type: .zCode)

        XCTAssertNoDifference(symbol, .statement(
            code: "Objects.thief.parent",
            type: .object.optional
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("thief")
            ], with: &localVariables)
        )
    }
}
