//
//  IsLessThanTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsLessThanTests: QuelboTests {
    let factory = Factories.IsLessThan.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("L?"))
        AssertSameFactory(factory, Game.findFactory("LESS?"))
    }

    func testLessThan() throws {
        let symbol = try factory.init([
            .decimal(2),
            .decimal(3),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isLessThan(3)",
            type: .bool,
            confidence: .certain
        ))
    }

    func testLessThanGlobal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .global("FOO"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isLessThan(foo)",
            type: .bool,
            confidence: .certain
        ))
    }

    func testLessThanLocal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .atom("BAR"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isLessThan(bar)",
            type: .bool,
            confidence: .certain
        ))
    }

    func testTypeMismatchThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2"),
                .decimal(3),
            ], with: &localVariables).process()
        )
    }

    func testNonIntegersThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("2"),
                .string("3"),
            ], with: &localVariables).process()
        )
    }
}
