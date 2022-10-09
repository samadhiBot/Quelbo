//
//  FirstChildTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class FirstChildTests: QuelboTests {
    let factory = Factories.FirstChild.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "clearing", type: .object, category: .rooms),
            .variable(id: "thief", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("FIRST?"))
    }

    func testThiefsFirstInventoryItem() throws {
        let symbol = try factory.init([
            .global(.atom("THIEF"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "thief.firstChild",
            type: .object
        ))
    }

    func testFirstItemInClearing() throws {
        let symbol = try factory.init([
            .global(.atom("CLEARING"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "clearing.firstChild",
            type: .object
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
