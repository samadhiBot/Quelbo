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

        try! Game.commit([
            .variable(id: "clearing", type: .object, category: .rooms),
            .variable(id: "thief", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("LOC", type: .zCode))
    }

    func testThiefsLocation() throws {
        let symbol = try factory.init([
            .global(.atom("THIEF"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "Objects.thief.parent",
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
