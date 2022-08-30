//
//  GetTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GetTests: QuelboTests {
    let factory = Factories.Get.self

    override func setUp() {
        super.setUp()

        try! Game.commit(.variable(id: "foo", type: .table, category: .globals))
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("GET"))
        AssertSameFactory(factory, Game.findFactory("GETB"))
    }

    func testGet() throws {
        let symbol = try factory.init([
            .global("FOO"),
            .decimal(2)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "try foo.get(at: 2)",
            type: .zilElement,
            confidence: .certain
        ))
    }

    func testNonTableThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("FOO"),
                .decimal(2)
            ], with: &localVariables).process()
        )
    }

    func testNonIndexThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .global("FOO"),
                .string("2")
            ], with: &localVariables).process()
        )
    }
}
