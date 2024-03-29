//
//  IsGreaterThanTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsGreaterThanTests: QuelboTests {
    let factory = Factories.IsGreaterThan.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "foo", type: .int, category: .globals)
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("G?"))
        AssertSameFactory(factory, Game.findFactory("GRTR?"))
    }

    func testIsGreaterThan() throws {
        let symbol = process("<G? 2 3>")

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isGreaterThan(3)",
            type: .bool
        ))
    }

    func testEvaluation() throws {
        XCTAssertNoDifference(
            process("<G? 2 1>", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<G? 3 1 2>", mode: .evaluate),
            .true
        )

        XCTAssertNoDifference(
            process("<G? 1 2>", mode: .evaluate),
            .false
        )

        XCTAssertNoDifference(
            process("<GRTR? 2 2>", mode: .evaluate),
            .false
        )
    }

    func testIsGreaterThanGlobal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .global(.atom("FOO")),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isGreaterThan(foo)",
            type: .bool
        ))
    }

    func testIsGreaterThanLocal() throws {
        let symbol = try factory.init([
            .decimal(2),
            .atom("BAR"),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "2.isGreaterThan(bar)",
            type: .bool
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
